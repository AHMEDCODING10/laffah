import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/usecases/request_ride_usecase.dart';
import '../../domain/usecases/cancel_ride_usecase.dart';
import '../../domain/usecases/get_trip_history_usecase.dart';
import '../../../parcel/domain/usecases/submit_parcel_order_usecase.dart';

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
  final SubmitParcelOrderUseCase submitParcelOrderUseCase;
  final GetTripHistoryUseCase getTripHistoryUseCase;

  RideBloc({
    required this.requestRideUseCase,
    required this.cancelRideUseCase,
    required this.submitParcelOrderUseCase,
    required this.getTripHistoryUseCase,
  }) : super(const RideInitial()) {
    on<CalculateSingleTripFare>(_onCalculateSingleTripFare);
    on<ConfirmUnifiedBooking>(_onConfirmUnifiedBooking);
    on<ConfirmBooking>(_onConfirmBooking);
    on<SubmitParcelOrder>(_onSubmitParcelOrder);
    on<CancelRideRequested>(_onCancelRideRequested);
    on<SimulateRideStep>(_onSimulateRideStep);
    on<ScheduleRide>(_onScheduleRide);
    on<LoadTripHistoryEvent>(_onLoadTripHistory);
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

  static Map<String, dynamic> calculateDynamicMetrics(String pickup, String dropoff) {
    final pClean = pickup.trim().toLowerCase();
    final dClean = dropoff.trim().toLowerCase();
    
    if (pClean.isEmpty || pClean.contains('حدة') || pClean.contains('hada') || 
        dClean.contains('صنعاء') || dClean.contains('sana') || dClean.isEmpty) {
      return {
        'distance': 7.2,
        'duration': 18,
        'fare': 2450.0,
      };
    }

    final combined = '$pickup|$dropoff';
    int hash = 0;
    for (int i = 0; i < combined.length; i++) {
      hash = combined.codeUnitAt(i) + ((hash << 5) - hash);
    }
    hash = hash.abs();

    final double distance = 3.2 + (hash % 88) / 10.0;
    final int duration = (distance * 2.1).round() + 3 + (hash % 5);
    final double rawPrice = 500.0 + (distance * 200.0) + (duration * 25.0);
    final double finalPrice = ((rawPrice / 50.0).round() * 50.0);

    return {
      'distance': double.parse(distance.toStringAsFixed(1)),
      'duration': duration,
      'fare': finalPrice,
    };
  }

  FutureOr<void> _onCalculateSingleTripFare(
    CalculateSingleTripFare event,
    Emitter<RideState> emit,
  ) async {
    emit(const RideLoading());
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
      rideType: 'laffah',
      expectedPrice: event.fare,
    );

    result.fold(
      (failure) => emit(RideError(failure.message)),
      (rideEntity) {
        emit(RideBookingConfirmed(
          pickup: rideEntity.pickupLocation,
          dropoff: rideEntity.dropoffLocation,
          selectedOption: selectedOption,
          captainName: rideEntity.captainName ?? 'قيد البحث',
          captainPhone: '',
          vehicleModel: rideEntity.vehicleModel ?? '',
          vehiclePlate: rideEntity.vehiclePlate ?? '',
          rating: rideEntity.rating ?? 5.0,
          status: rideEntity.status,
          rideId: rideEntity.id,
        ));
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
      rideType: event.rideType,
      expectedPrice: calculatedPrice,
    );

    result.fold(
      (failure) => emit(RideError(failure.message)),
      (rideEntity) {
        emit(RideBookingConfirmed(
          pickup: rideEntity.pickupLocation,
          dropoff: rideEntity.dropoffLocation,
          selectedOption: selectedOption,
          captainName: rideEntity.captainName ?? 'قيد البحث',
          captainPhone: '',
          vehicleModel: rideEntity.vehicleModel ?? '',
          vehiclePlate: rideEntity.vehiclePlate ?? '',
          rating: rideEntity.rating ?? 5.0,
          status: rideEntity.status,
          rideId: rideEntity.id,
        ));
      },
    );
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
      (failure) => emit(RideError('فشل تقديم طلب إرسال الطرد: ${failure.message}')),
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
}

