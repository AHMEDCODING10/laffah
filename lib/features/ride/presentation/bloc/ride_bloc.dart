import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/usecases/request_ride_usecase.dart';
import '../../domain/usecases/cancel_ride_usecase.dart';
import '../../domain/usecases/track_ride_usecase.dart';
import '../../domain/usecases/get_trip_history_usecase.dart';
import '../../domain/usecases/rate_trip_use_case.dart';
import '../../../parcel/domain/usecases/submit_parcel_order_usecase.dart';
import '../../../../core/services/echo_service.dart';
import '../../../../core/services/captain_trip_alert_sound_service.dart';

export 'ride_event.dart';
export 'ride_state.dart';

import 'ride_event.dart';
import 'ride_state.dart';

// ===========================================================================
// DATA LAYER MODELS (IMMUTABLE DTOs)
// ===========================================================================

@immutable
class ParcelData extends Equatable {
  final String senderName;
  final String senderPhone;
  final String receiverName;
  final String receiverPhone;
  final String parcelType;
  final String size;
  final String notes;

  const ParcelData({
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.parcelType,
    required this.size,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        senderName,
        senderPhone,
        receiverName,
        receiverPhone,
        parcelType,
        size,
        notes,
      ];
}

@immutable
class RideOption extends Equatable {
  final String id;
  final String titleAr;
  final String titleEn;
  final double basePrice;
  final int etaMinutes;
  final String iconKey;
  final String descriptionAr;

  const RideOption({
    required this.id,
    required this.titleAr,
    required this.titleEn,
    required this.basePrice,
    required this.etaMinutes,
    required this.iconKey,
    required this.descriptionAr,
  });

  @override
  List<Object?> get props => [
        id,
        titleAr,
        titleEn,
        basePrice,
        etaMinutes,
        iconKey,
        descriptionAr,
      ];
}

// ===========================================================================
// RIDE BLOC (Clean Architecture)
// ===========================================================================

class RideBloc extends Bloc<RideEvent, RideState> {
  final RequestRideUseCase requestRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final TrackRideUseCase trackRideUseCase;
  final SubmitParcelOrderUseCase submitParcelOrderUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;
  final RateTripUseCase rateTripUseCase;
  final CaptainTripAlertSoundService alertSoundService;
  final EchoService _echoService = EchoService();

  String? _currentActiveRideId;
  Timer? _smartPollingTimer;

  RideBloc({
    required this.requestRideUseCase,
    required this.cancelRideUseCase,
    required this.trackRideUseCase,
    required this.submitParcelOrderUseCase,
    required this.getTripHistoryUseCase,
    required this.rateTripUseCase,
    required this.alertSoundService,
  }) : super(const RideInitial()) {
    on<CalculateSingleTripFare>(_onCalculateSingleTripFare);
    on<ConfirmUnifiedBooking>(_onConfirmUnifiedBooking);
    on<ConfirmBooking>(_onConfirmBooking);
    on<SubmitParcelOrder>(_onSubmitParcelOrder);
    on<CancelRideRequested>(_onCancelRideRequested);
    on<SubmitTripRating>(_onSubmitTripRating);
    on<SimulateRideStep>(_onSimulateRideStep);
    on<ScheduleRide>(_onScheduleRide);
    on<LoadTripHistoryEvent>(_onLoadTripHistory);
    on<TripStatusUpdatedFromWebSocket>(_onTripStatusUpdatedFromWebSocket);
    on<ActiveRidePolledStatusUpdated>(_onActiveRidePolledStatusUpdated);
  }

  static const List<RideOption> rideTiers = [
    RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: 2450.0,
      etaMinutes: 18,
      iconKey: 'car',
      descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
    ),
  ];

  static Map<String, dynamic> calculateDynamicMetrics(
      String pickup, String dropoff) {
    final pClean = pickup.trim().toLowerCase();
    final dClean = dropoff.trim().toLowerCase();

    if (pClean.isEmpty ||
        pClean.contains('حدة') ||
        pClean.contains('hada') ||
        dClean.contains('صنعاء') ||
        dClean.contains('sana') ||
        dClean.isEmpty) {
      return {
        'distance': 4.2,
        'duration': 14,
        'fare': 1250.0,
      };
    } else if (pClean.contains('تحرير') ||
        pClean.contains('tahrir') ||
        dClean.contains('جامعة') ||
        dClean.contains('university')) {
      return {
        'distance': 6.8,
        'duration': 19,
        'fare': 1850.0,
      };
    } else {
      final calculatedDist = 3.5 + (pickup.length % 5) * 1.5;
      final calculatedDur = (calculatedDist * 3.0).round();
      final calculatedFare = (500 + (calculatedDist * 200)).roundToDouble();

      return {
        'distance': calculatedDist,
        'duration': calculatedDur,
        'fare': calculatedFare,
      };
    }
  }

  FutureOr<void> _onCalculateSingleTripFare(
    CalculateSingleTripFare event,
    Emitter<RideState> emit,
  ) {
    final metrics = calculateDynamicMetrics(event.pickup, event.dropoff);

    emit(RideOptionsLoaded(
      pickup: event.pickup,
      dropoff: event.dropoff,
      options: [
        RideOption(
          id: 'laffah',
          titleAr: 'لَفّة',
          titleEn: 'Laffah',
          basePrice: metrics['fare'],
          etaMinutes: metrics['duration'],
          iconKey: 'car',
          descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
        )
      ],
      distance: metrics['distance'],
      duration: metrics['duration'],
      fare: metrics['fare'],
    ));
  }

  FutureOr<void> _onConfirmUnifiedBooking(
    ConfirmUnifiedBooking event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    final selectedOption = RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: event.fare,
      etaMinutes: event.duration,
      iconKey: 'car',
      descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
    );

    final result = await requestRideUseCase(
      pickupLocation: event.pickup,
      dropoffLocation: event.dropoff,
      pickupLatitude: event.pickupLatitude,
      pickupLongitude: event.pickupLongitude,
      dropoffLatitude: event.dropoffLatitude,
      dropoffLongitude: event.dropoffLongitude,
      rideType: 'ride',
      expectedPrice: event.fare,
      stops: event.stops,
    );

    result.fold(
      (failure) => emit(RideError(failure.message)),
      (rideEntity) {
        _currentActiveRideId = rideEntity.id;
        _echoService.listenToTripStatus(
          rideEntity.id,
          (data) => add(TripStatusUpdatedFromWebSocket(data)),
        );

        emit(RideBookingConfirmed(
          pickup: rideEntity.pickupLocation.isNotEmpty ? rideEntity.pickupLocation : event.pickup,
          dropoff: rideEntity.dropoffLocation.isNotEmpty ? rideEntity.dropoffLocation : event.dropoff,
          selectedOption: selectedOption,
          captainName: rideEntity.captainName ?? 'قيد البحث',
          captainPhone: rideEntity.captainPhone ?? '',
          vehicleModel: rideEntity.vehicleModel ?? 'دراجة نارية',
          vehiclePlate: rideEntity.vehiclePlate ?? '',
          rating: rideEntity.rating ?? 5.0,
          status: rideEntity.status,
          rideId: rideEntity.id,
        ));

        // Start Periodic Smart Polling to detect when Captain accepts
        _startSmartPolling(rideEntity.id, selectedOption, event.pickup, event.dropoff);
      },
    );
  }

  FutureOr<void> _onConfirmBooking(
    ConfirmBooking event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    final metrics = calculateDynamicMetrics(event.pickup, event.dropoff);
    final double calculatedPrice = metrics['fare'];
    final int duration = metrics['duration'];

    final selectedOption = RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: calculatedPrice,
      etaMinutes: duration,
      iconKey: 'car',
      descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
    );

    final result = await requestRideUseCase(
      pickupLocation: event.pickup,
      dropoffLocation: event.dropoff,
      pickupLatitude: event.pickupLatitude,
      pickupLongitude: event.pickupLongitude,
      dropoffLatitude: event.dropoffLatitude,
      dropoffLongitude: event.dropoffLongitude,
      rideType: event.rideType,
      expectedPrice: calculatedPrice,
    );

    result.fold(
      (failure) => emit(RideError(failure.message)),
      (rideEntity) {
        _currentActiveRideId = rideEntity.id;
        _echoService.listenToTripStatus(
          rideEntity.id,
          (data) => add(TripStatusUpdatedFromWebSocket(data)),
        );

        emit(RideBookingConfirmed(
          pickup: rideEntity.pickupLocation.isNotEmpty ? rideEntity.pickupLocation : event.pickup,
          dropoff: rideEntity.dropoffLocation.isNotEmpty ? rideEntity.dropoffLocation : event.dropoff,
          selectedOption: selectedOption,
          captainName: rideEntity.captainName ?? 'قيد البحث',
          captainPhone: rideEntity.captainPhone ?? '',
          vehicleModel: rideEntity.vehicleModel ?? 'دراجة نارية',
          vehiclePlate: rideEntity.vehiclePlate ?? '',
          rating: rideEntity.rating ?? 5.0,
          status: rideEntity.status,
          rideId: rideEntity.id,
        ));

        // Start Periodic Smart Polling to detect when Captain accepts
        _startSmartPolling(rideEntity.id, selectedOption, event.pickup, event.dropoff);
      },
    );
  }

  /// Periodic Smart Polling for Ride Status (Every 2.5 seconds)
  void _startSmartPolling(
    String rideId,
    RideOption option,
    String pickup,
    String dropoff,
  ) {
    _stopSmartPolling();
    _smartPollingTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) async {
      final res = await trackRideUseCase.fetchRide(rideId);
      res.fold(
        (failure) => null,
        (ride) {
          add(ActiveRidePolledStatusUpdated(
            status: ride.status,
            captainName: ride.captainName,
            captainPhone: ride.captainPhone,
            vehicleModel: ride.vehicleModel,
            vehiclePlate: ride.vehiclePlate,
            rating: ride.rating ?? 5.0,
            rideId: rideId,
            option: option,
            pickup: ride.pickupLocation.isNotEmpty ? ride.pickupLocation : pickup,
            dropoff: ride.dropoffLocation.isNotEmpty ? ride.dropoffLocation : dropoff,
          ));
        },
      );
    });
  }

  void _stopSmartPolling() {
    _smartPollingTimer?.cancel();
    _smartPollingTimer = null;
  }

  void _onActiveRidePolledStatusUpdated(
    ActiveRidePolledStatusUpdated event,
    Emitter<RideState> emit,
  ) {
    final s = event.status.toLowerCase();
    final bool wasSearching = state is RideBookingConfirmed &&
        ((state as RideBookingConfirmed).captainName == 'قيد البحث' ||
            (state as RideBookingConfirmed).status == 'pending');
    final bool isArrivingNow = s == 'arrived' &&
        state is RideBookingConfirmed &&
        (state as RideBookingConfirmed).status != 'arrived';
    final bool isStartingNow = (s == 'in_transit' || s == 'started') &&
        state is RideBookingConfirmed &&
        (state as RideBookingConfirmed).status != 'in_transit' &&
        (state as RideBookingConfirmed).status != 'started';

    if (s == 'accepted' || s == 'arrived' || s == 'in_transit' || s == 'started') {
      if (wasSearching || isArrivingNow || isStartingNow) {
        // Play discrete chime on lifecycle progression
        alertSoundService.playSimpleTripAlert();
      }

      emit(RideBookingConfirmed(
        pickup: event.pickup,
        dropoff: event.dropoff,
        selectedOption: event.option,
        captainName: (event.captainName != null && event.captainName!.isNotEmpty)
            ? event.captainName!
            : 'كابتن لَفَّة',
        captainPhone: event.captainPhone ?? '',
        vehicleModel: (event.vehicleModel != null && event.vehicleModel!.isNotEmpty)
            ? event.vehicleModel!
            : 'دراجة نارية',
        vehiclePlate: (event.vehiclePlate != null && event.vehiclePlate!.isNotEmpty)
            ? event.vehiclePlate!
            : '---',
        rating: event.rating,
        status: s == 'started' ? 'in_transit' : s,
        rideId: event.rideId,
      ));
    } else if (s == 'completed') {
      _stopSmartPolling();
      alertSoundService.playSimpleTripAlert();
      if (state is RideBookingConfirmed) {
        final sObj = state as RideBookingConfirmed;
        emit(sObj.copyWith(status: 'completed'));
      } else {
        emit(RideBookingConfirmed(
          pickup: event.pickup,
          dropoff: event.dropoff,
          selectedOption: event.option,
          captainName: (event.captainName != null && event.captainName!.isNotEmpty)
              ? event.captainName!
              : 'كابتن لَفَّة',
          captainPhone: event.captainPhone ?? '',
          vehicleModel: (event.vehicleModel != null && event.vehicleModel!.isNotEmpty)
              ? event.vehicleModel!
              : 'دراجة نارية',
          vehiclePlate: (event.vehiclePlate != null && event.vehiclePlate!.isNotEmpty)
              ? event.vehiclePlate!
              : '---',
          rating: event.rating,
          status: 'completed',
          rideId: event.rideId,
        ));
      }
    } else if (s == 'cancelled') {
      _stopSmartPolling();
      emit(const RideInitial());
    }
  }

  FutureOr<void> _onSubmitParcelOrder(
    SubmitParcelOrder event,
    Emitter<RideState> emit,
  ) async {
    if (event.data.senderName.isEmpty || event.data.receiverName.isEmpty) {
      emit(const RideError('الرجاء إدخال اسم المرسل والمستلم بشكل صحيح'));
      return;
    }
    if (event.data.senderPhone.isEmpty || event.data.receiverPhone.isEmpty) {
      emit(const RideError('الرجاء إدخال رقم هاتف المرسل والمستلم'));
      return;
    }

    emit(const RideLoading());

    final result = await submitParcelOrderUseCase(
      senderName: event.data.senderName,
      senderPhone: event.data.senderPhone,
      receiverName: event.data.receiverName,
      receiverPhone: event.data.receiverPhone,
      parcelType: event.data.parcelType,
      size: event.data.size,
      notes: event.data.notes,
    );

    result.fold(
      (failure) =>
          emit(RideError('فشل تقديم طلب إرسال الطرد: ${failure.message}')),
      (parcelEntity) {
        emit(ParcelSubmitted(
          data: event.data,
          trackingId: parcelEntity.id,
          price: parcelEntity.price,
        ));
      },
    );
  }

  FutureOr<void> _onCancelRideRequested(
    CancelRideRequested event,
    Emitter<RideState> emit,
  ) async {
    _stopSmartPolling();
    if (_currentActiveRideId != null) {
      _echoService.stopListeningToTripStatus(_currentActiveRideId!);
      _currentActiveRideId = null;
    }
    if (state is RideBookingConfirmed) {
      final rideId = (state as RideBookingConfirmed).rideId;
      if (rideId != null) {
        emit(const RideLoading());
        final result = await cancelRideUseCase(rideId);
        result.fold(
          (failure) => emit(RideError(failure.message)),
          (_) => emit(const RideInitial()),
        );
        return;
      }
    }
    emit(const RideInitial());
  }

  FutureOr<void> _onSimulateRideStep(
    SimulateRideStep event,
    Emitter<RideState> emit,
  ) {
    final stepStr = event.step.toString();
    if (stepStr == 'found' || stepStr == '1') {
      emit(const RideAccepted(
        captainName: 'أحمد محمد',
        vehicleModel: 'تويوتا كورولا • أبيض',
        vehiclePlate: '77213',
        captainRating: 4.9,
        eta: '4 دقائق',
      ));
    } else if (stepStr == 'in_progress' || stepStr == '2') {
      emit(const RideInProgress(etaToDestination: '10 دقائق'));
    } else if (stepStr == 'completed' || stepStr == '3') {
      emit(const RideCompleted());
    } else if (stepStr == 'finding' || stepStr == '0') {
      emit(const RideSearching());
    }
  }

  FutureOr<void> _onScheduleRide(
    ScheduleRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());
    await Future.delayed(const Duration(milliseconds: 300));
    emit(const RideScheduledSuccess());
  }

  /// Loads trip history from the real backend API
  Future<void> _onLoadTripHistory(
    LoadTripHistoryEvent event,
    Emitter<RideState> emit,
  ) async {
    emit(const TripHistoryLoading());
    final result = await getTripHistoryUseCase();
    result.fold(
      (failure) => emit(TripHistoryError(failure.message)),
      (trips) => emit(TripHistoryLoaded(trips)),
    );
  }

  /// Handles real-time WebSocket trip status updates (accepted, arrived, in_transit, completed, cancelled)
  FutureOr<void> _onTripStatusUpdatedFromWebSocket(
    TripStatusUpdatedFromWebSocket event,
    Emitter<RideState> emit,
  ) {
    final data = event.data;
    final status = (data['status'] ?? '').toString().toLowerCase();

    if (status == 'accepted' || status == 'arrived') {
      alertSoundService.playSimpleTripAlert();
      if (state is RideBookingConfirmed) {
        final s = state as RideBookingConfirmed;
        emit(s.copyWith(
          captainName: data['captain_name']?.toString() ?? s.captainName,
          captainPhone: data['captain_phone']?.toString() ?? s.captainPhone,
          vehicleModel: data['vehicle_model']?.toString() ?? s.vehicleModel,
          vehiclePlate: data['vehicle_plate']?.toString() ?? (data['plate_number']?.toString() ?? s.vehiclePlate),
          rating: (data['rating'] is num)
              ? (data['rating'] as num).toDouble()
              : ((data['captain_rating'] is num)
                  ? (data['captain_rating'] as num).toDouble()
                  : s.rating),
          status: status,
        ));
      } else {
        emit(RideAccepted(
          captainName: data['captain_name']?.toString() ?? 'كابتن لَفَّة',
          vehicleModel: data['vehicle_model']?.toString() ?? 'دراجة نارية',
          vehiclePlate: data['vehicle_plate']?.toString() ?? (data['plate_number']?.toString() ?? '---'),
          captainRating: (data['rating'] is num)
              ? (data['rating'] as num).toDouble()
              : ((data['captain_rating'] is num)
                  ? (data['captain_rating'] as num).toDouble()
                  : 5.0),
          eta: status == 'arrived' ? 'وصل الكابتن' : '3 دقائق',
        ));
      }
    } else if (status == 'in_transit' || status == 'started') {
      alertSoundService.playSimpleTripAlert();
      if (state is RideBookingConfirmed) {
        final s = state as RideBookingConfirmed;
        emit(s.copyWith(status: 'in_transit'));
      } else {
        emit(const RideInProgress(etaToDestination: 'في الطريق إلى الوجهة'));
      }
    } else if (status == 'completed') {
      _stopSmartPolling();
      alertSoundService.playSimpleTripAlert();
      if (_currentActiveRideId != null) {
        _echoService.stopListeningToTripStatus(_currentActiveRideId!);
        _currentActiveRideId = null;
      }
      if (state is RideBookingConfirmed) {
        final s = state as RideBookingConfirmed;
        emit(s.copyWith(status: 'completed'));
      } else {
        emit(const RideCompleted());
      }
    } else if (status == 'cancelled') {
      _stopSmartPolling();
      if (_currentActiveRideId != null) {
        _echoService.stopListeningToTripStatus(_currentActiveRideId!);
        _currentActiveRideId = null;
      }
      emit(const RideInitial());
    }
  }

  FutureOr<void> _onSubmitTripRating(
    SubmitTripRating event,
    Emitter<RideState> emit,
  ) async {
    final result = await rateTripUseCase(
      tripId: event.tripId,
      rating: event.rating,
      review: event.review,
    );
    result.fold(
      (failure) => emit(RideError('فشل إرسال التقييم: ${failure.message}')),
      (_) {
        _stopSmartPolling();
        emit(const RideInitial());
      },
    );
  }

  @override
  Future<void> close() {
    _stopSmartPolling();
    if (_currentActiveRideId != null) {
      _echoService.stopListeningToTripStatus(_currentActiveRideId!);
    }
    return super.close();
  }
}
