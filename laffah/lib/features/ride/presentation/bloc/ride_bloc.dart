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
import '../../data/datasources/ride_remote_data_source.dart';

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
  final String? pickupAddress;
  final String? dropoffAddress;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? price;

  const ParcelData({
    required this.senderName,
    required this.senderPhone,
    required this.receiverName,
    required this.receiverPhone,
    required this.parcelType,
    required this.size,
    required this.notes,
    this.pickupAddress,
    this.dropoffAddress,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.price,
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
        pickupAddress,
        dropoffAddress,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        price,
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
  final RateTripUseCase? rateTripUseCase;
  final CaptainTripAlertSoundService alertSoundService;
  final RideRemoteDataSource remoteDataSource;
  final EchoService _echoService = EchoService();

  String? _currentActiveRideId;
  Timer? _smartPollingTimer;

  RideBloc({
    required this.requestRideUseCase,
    required this.cancelRideUseCase,
    required this.trackRideUseCase,
    required this.submitParcelOrderUseCase,
    required this.getTripHistoryUseCase,
    this.rateTripUseCase,
    required this.alertSoundService,
    required this.remoteDataSource,
  }) : super(const RideInitial()) {
    on<CalculateSingleTripFare>(_onCalculateSingleTripFare);
    on<ConfirmUnifiedBooking>(_onConfirmUnifiedBooking);
    on<ConfirmBooking>(_onConfirmBooking);
    on<SubmitParcelOrder>(_onSubmitParcelOrder);
    on<CancelRideRequested>(_onCancelRideRequested);
    on<SimulateRideStep>(_onSimulateRideStep);
    on<ScheduleRide>(_onScheduleRide);
    on<LoadTripHistoryEvent>(_onLoadTripHistory);
    on<TripStatusUpdatedFromWebSocket>(_onTripStatusUpdatedFromWebSocket);
    on<ActiveRidePolledStatusUpdated>(_onActiveRidePolledStatusUpdated);
    on<RateTripRequested>(_onRateTripRequested);
    on<DeleteTripFromHistory>(_onDeleteTripFromHistory);
    on<ResetRideState>(_onResetRideState);
  }

  Future<void> _onDeleteTripFromHistory(
    DeleteTripFromHistory event,
    Emitter<RideState> emit,
  ) async {
    try {
      await remoteDataSource.deleteTrip(event.tripId, isParcel: event.isParcel);
    } catch (_) {}

    if (state is TripHistoryLoaded) {
      final currentList = (state as TripHistoryLoaded).trips;
      final updatedList = currentList
          .where((t) {
            final itemIsParcel = (t['isParcel'] == true || t['is_parcel'] == true || t['type'] == 'parcel' || t['type'] == 'delivery');
            return !(t['id']?.toString() == event.tripId.toString() && itemIsParcel == event.isParcel);
          })
          .toList();
      emit(TripHistoryLoaded(updatedList));
    }
  }

  Future<void> _onRateTripRequested(
    RateTripRequested event,
    Emitter<RideState> emit,
  ) async {
    if (rateTripUseCase != null) {
      await rateTripUseCase!(
        tripId: event.tripId,
        rating: event.rating,
        review: event.comment,
      );
    }
  }

  void _onResetRideState(ResetRideState event, Emitter<RideState> emit) {
    _stopSmartPolling();
    if (_currentActiveRideId != null) {
      _echoService.stopListeningToTripStatus(_currentActiveRideId!);
      _currentActiveRideId = null;
    }
    emit(const RideInitial());
  }

  // Backend-Driven Fare Estimation
  // All fare values come from the backend's /trips/estimate endpoint
  // which reads from the admin settings table (cached 15 min).
  // Zero client-side arithmetic — no hardcoded base fares or per-km rates.
  FutureOr<void> _onCalculateSingleTripFare(
    CalculateSingleTripFare event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());

    if ((event.pickupLatitude ?? 0) == 0 || (event.pickupLongitude ?? 0) == 0 || (event.dropoffLatitude ?? 0) == 0 || (event.dropoffLongitude ?? 0) == 0) {
      emit(const RideError('يرجى تحديد موقع الاستلام والتسليم على الخريطة بدقة'));
      return;
    }

    final result = await remoteDataSource.estimateFare(
      pickupLatitude: event.pickupLatitude!,
      pickupLongitude: event.pickupLongitude!,
      dropoffLatitude: event.dropoffLatitude!,
      dropoffLongitude: event.dropoffLongitude!,
      stops: event.stops,
    );

    if (result.isEmpty) {
      emit(const RideError('تعذر حساب تكلفة الرحلة. يرجى التحقق من الإنترنت والمحاولة مجدداً'));
      return;
    }

    // Backend returns integer YER price (already min-floored & ceil-rounded)
    final int estimatedPrice = (result['estimated_price'] as num?)?.toInt() ?? 0;
    final double distanceKm = (result['distance_km'] as num?)?.toDouble() ?? 0.0;
    final int durationMin = ((distanceKm / 25.0) * 60).ceil().clamp(3, 120);
    final int nearbyCaptains = (result['nearby_captains'] as num?)?.toInt() ?? 0;

    emit(RideOptionsLoaded(
      pickup: event.pickup,
      dropoff: event.dropoff,
      options: [
        RideOption(
          id: 'laffah',
          titleAr: 'لَفّة',
          titleEn: 'Laffah',
          basePrice: estimatedPrice.toDouble(),
          etaMinutes: durationMin,
          iconKey: 'car',
          descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
        )
      ],
      distance: distanceKm,
      duration: durationMin,
      fare: estimatedPrice.toDouble(),
      nearbyCaptainsCount: nearbyCaptains,
    ));
  }

  FutureOr<void> _onConfirmUnifiedBooking(
    ConfirmUnifiedBooking event,
    Emitter<RideState> emit,
  ) async {
    final selectedOption = RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: event.fare,
      etaMinutes: event.duration,
      iconKey: 'car',
      descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
    );

    int nearbyCaptains = 0;
    if (state is RideOptionsLoaded) {
      nearbyCaptains = (state as RideOptionsLoaded).nearbyCaptainsCount;
    }

    // 1. Instantly emit Searching / Pending state so user immediately sees the Searching Radar
    emit(RideBookingConfirmed(
      pickup: event.pickup,
      dropoff: event.dropoff,
      selectedOption: selectedOption,
      captainName: 'قيد البحث',
      captainPhone: '',
      vehicleModel: 'دراجة نارية',
      vehiclePlate: '',
      rating: 5.0,
      status: 'pending',
      nearbyCaptainsCount: nearbyCaptains,
    ));

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
      isScheduled: event.isScheduled,
      scheduledTime: event.scheduledTime,
      paymentMethod: event.paymentMethod,
    );

    result.fold(
      (failure) {
        if (event.isScheduled) {
          emit(const RideInitial());
        }
        emit(RideError(failure.message));
      },
      (rideEntity) {
        if (event.isScheduled) {
          emit(const RideScheduledSuccess());
          return;
        }

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
    double calculatedPrice = 0.0;
    int duration = 0;

    if ((event.pickupLatitude ?? 0) != 0 && (event.dropoffLatitude ?? 0) != 0) {
      try {
        final estimate = await remoteDataSource.estimateFare(
          pickupLatitude: event.pickupLatitude!,
          pickupLongitude: event.pickupLongitude ?? 0,
          dropoffLatitude: event.dropoffLatitude!,
          dropoffLongitude: event.dropoffLongitude ?? 0,
          stops: null,
        );
        if (estimate['estimated_price'] != null) {
          calculatedPrice = (estimate['estimated_price'] as num).toDouble();
          duration = ((estimate['distance_km'] as num? ?? 5.0) / 25.0 * 60).ceil().clamp(3, 120);
        }
      } catch (_) {}
    }

    final selectedOption = RideOption(
      id: 'laffah',
      titleAr: 'لَفّة',
      titleEn: 'Laffah',
      basePrice: calculatedPrice,
      etaMinutes: duration,
      iconKey: 'car',
      descriptionAr: 'الخيار الوحيد المتاح: لَفّة',
    );

    // 1. Instantly transition to Searching State on the map
    emit(RideBookingConfirmed(
      pickup: event.pickup,
      dropoff: event.dropoff,
      selectedOption: selectedOption,
      captainName: 'قيد البحث',
      captainPhone: '',
      vehicleModel: 'دراجة نارية',
      vehiclePlate: '',
      rating: 5.0,
      status: 'pending',
    ));

    final result = await requestRideUseCase(
      pickupLocation: event.pickup,
      dropoffLocation: event.dropoff,
      pickupLatitude: event.pickupLatitude,
      pickupLongitude: event.pickupLongitude,
      dropoffLatitude: event.dropoffLatitude,
      dropoffLongitude: event.dropoffLongitude,
      rideType: event.rideType,
      expectedPrice: calculatedPrice,
      paymentMethod: event.paymentMethod,
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
          distance: rideEntity.distanceString,
          duration: rideEntity.durationString,
        ));

        // Start Periodic Smart Polling to detect when Captain accepts
        _startSmartPolling(rideEntity.id, selectedOption, event.pickup, event.dropoff);
      },
    );
  }

  /// Periodic Smart Polling for Ride Status (Reliable fallback at 10s)
  void _startSmartPolling(
    String rideId,
    RideOption option,
    String pickup,
    String dropoff,
  ) {
    _stopSmartPolling();
    _smartPollingTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      final res = await trackRideUseCase.fetchRide(rideId);
      res.fold(
        (failure) => null,
        (ride) {
          if (ride.status == 'completed' || ride.status == 'cancelled') {
            _stopSmartPolling();
          }
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
            backendFare: ride.price > 0 ? ride.price : null,
            distance: ride.distanceString,
            duration: ride.durationString,
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

    // Build option with authoritative backend fare (if available)
    final RideOption effectiveOption = (event.backendFare != null && event.backendFare! > 0)
        ? RideOption(
            id: event.option.id,
            titleAr: event.option.titleAr,
            titleEn: event.option.titleEn,
            basePrice: event.backendFare!, // ← Backend-authoritative price
            etaMinutes: event.option.etaMinutes,
            iconKey: event.option.iconKey,
            descriptionAr: event.option.descriptionAr,
          )
        : event.option;

    if (s == 'accepted' || s == 'arrived' || s == 'in_transit' || s == 'started') {
      if (wasSearching) {
        // Captain just accepted! Play simple discrete chime
        alertSoundService.playSimpleTripAlert();
      }

      emit(RideBookingConfirmed(
        pickup: event.pickup,
        dropoff: event.dropoff,
        selectedOption: effectiveOption,
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
        status: s,
        rideId: event.rideId,
        distance: event.distance,
        duration: event.duration,
      ));
    } else if (s == 'completed') {
      _stopSmartPolling();
      alertSoundService.playSimpleTripAlert();
      emit(RideBookingConfirmed(
        pickup: event.pickup,
        dropoff: event.dropoff,
        selectedOption: effectiveOption,
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
        distance: event.distance,
        duration: event.duration,
      ));
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
      pickupAddress: event.data.pickupAddress,
      pickupLatitude: event.data.pickupLatitude,
      pickupLongitude: event.data.pickupLongitude,
      dropoffAddress: event.data.dropoffAddress,
      dropoffLatitude: event.data.dropoffLatitude,
      dropoffLongitude: event.data.dropoffLongitude,
      parcelType: event.data.parcelType,
      size: event.data.size,
      notes: event.data.notes,
      price: event.data.price,
    );

    result.fold(
      (failure) =>
          emit(RideError('فشل تقديم طلب إرسال الطرد: ${failure.message}')),
      (parcelEntity) {
        _currentActiveRideId = parcelEntity.id;
        _echoService.listenToTripStatus(
          parcelEntity.id,
          (data) => add(TripStatusUpdatedFromWebSocket(data)),
        );

        // Fallback fetch
        _startSmartPolling(
          parcelEntity.id,
          RideOption(
            id: 'parcel',
            titleAr: 'طرد',
            titleEn: 'Parcel',
            basePrice: parcelEntity.price,
            etaMinutes: 10,
            iconKey: 'box',
            descriptionAr: 'توصيل طرود',
          ),
          'موقع استلام الطرد',
          'موقع تسليم الطرد',
        );

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

    final targetTripId = event.tripId ??
        (state is RideBookingConfirmed
            ? (state as RideBookingConfirmed).rideId
            : null);

    if (targetTripId != null && targetTripId.isNotEmpty) {
      await cancelRideUseCase(targetTripId, isParcel: event.isParcel);
    }

    if (state is TripHistoryLoaded) {
      final currentList = (state as TripHistoryLoaded).trips;
      final nowStr = DateTime.now().toIso8601String();
      final updatedList = currentList.map((t) {
        final itemIsParcel = (t['isParcel'] == true || t['is_parcel'] == true || t['type'] == 'parcel' || t['type'] == 'delivery');
        if (t['id']?.toString() == targetTripId?.toString() && itemIsParcel == event.isParcel) {
          final updated = Map<String, dynamic>.from(t);
          updated['status'] = 'cancelled';
          updated['cancelled_at'] = nowStr;
          updated['updated_at'] = nowStr;
          return updated;
        }
        return t;
      }).toList();
      emit(TripHistoryLoaded(updatedList));
      return;
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
        tripId: 'LF-8492',
        captainName: 'أحمد محمد',
        captainPhone: '+967 777 000 000',
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

  Future<void> _onScheduleRide(
    ScheduleRide event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());
    await Future.delayed(const Duration(seconds: 1));
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
  void _onTripStatusUpdatedFromWebSocket(
    TripStatusUpdatedFromWebSocket event,
    Emitter<RideState> emit,
  ) {
    final data = event.data;
    final status = data['status']?.toString();

    if (status == 'accepted') {
      alertSoundService.playSimpleTripAlert();
      if (state is RideBookingConfirmed) {
        final s = state as RideBookingConfirmed;
        emit(s.copyWith(
          captainName: data['captain_name']?.toString() ?? 'كابتن لَفَّة',
          captainPhone: data['captain_phone']?.toString() ?? '',
          vehicleModel: data['vehicle_model']?.toString() ?? 'دراجة نارية',
          vehiclePlate: data['plate_number']?.toString() ?? '---',
          rating: (data['captain_rating'] is num)
              ? (data['captain_rating'] as num).toDouble()
              : 5.0,
          status: 'accepted',
          distance: data['distance']?.toString(),
          duration: data['duration']?.toString(),
        ));
      } else {
        emit(RideAccepted(
          tripId: (data['trip_id'] ?? data['id'] ?? '').toString(),
          captainName: data['captain_name']?.toString() ?? 'كابتن لَفَّة',
          captainPhone: data['captain_phone']?.toString() ?? '',
          vehicleModel: data['vehicle_model']?.toString() ?? 'دراجة نارية',
          vehiclePlate: data['plate_number']?.toString() ?? '---',
          captainRating: (data['captain_rating'] is num)
              ? (data['captain_rating'] as num).toDouble()
              : 5.0,
          eta: '3 دقائق',
        ));
      }
    } else if (status == 'arrived') {
      if (state is RideBookingConfirmed) {
        final s = state as RideBookingConfirmed;
        emit(s.copyWith(status: 'arrived'));
      } else {
        emit(const RideInProgress(etaToDestination: 'الكابتن وصل لموقعك'));
      }
    } else if (status == 'in_transit' || status == 'started') {
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
        emit(s.copyWith(
          status: 'completed',
          distance: data['distance']?.toString(),
          duration: data['duration']?.toString(),
        ));
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

  @override
  Future<void> close() {
    _stopSmartPolling();
    if (_currentActiveRideId != null) {
      _echoService.stopListeningToTripStatus(_currentActiveRideId!);
    }
    return super.close();
  }
}
