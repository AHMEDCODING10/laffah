import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../domain/usecases/request_ride_usecase.dart';
import '../../domain/usecases/cancel_ride_usecase.dart';
import '../../../parcel/domain/usecases/submit_parcel_order_usecase.dart';

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
// RIDE EVENTS
// ===========================================================================

@immutable
abstract class RideEvent extends Equatable {
  const RideEvent();

  @override
  List<Object?> get props => [];
}

class CalculateSingleTripFare extends RideEvent {
  final String pickup;
  final String dropoff;

  const CalculateSingleTripFare({
    required this.pickup,
    required this.dropoff,
  });

  @override
  List<Object?> get props => [pickup, dropoff];
}

class ConfirmUnifiedBooking extends RideEvent {
  final String pickup;
  final String dropoff;
  final double fare;
  final double distance;
  final int duration;

  const ConfirmUnifiedBooking({
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props => [pickup, dropoff, fare, distance, duration];
}

class ConfirmBooking extends RideEvent {
  final String pickup;
  final String dropoff;
  final String rideType;

  const ConfirmBooking({
    required this.pickup,
    required this.dropoff,
    required this.rideType,
  });

  @override
  List<Object?> get props => [pickup, dropoff, rideType];
}

class SubmitParcelOrder extends RideEvent {
  final ParcelData data;

  const SubmitParcelOrder(this.data);

  @override
  List<Object?> get props => [data];
}

class CancelRideRequested extends RideEvent {
  final String? reason;

  const CancelRideRequested({this.reason});

  @override
  List<Object?> get props => [reason];
}

class SimulateRideStep extends RideEvent {
  final dynamic step;

  const SimulateRideStep({this.step});

  @override
  List<Object?> get props => [step];
}

// ===========================================================================
// RIDE STATES
// ===========================================================================

@immutable
abstract class RideState extends Equatable {
  const RideState();

  @override
  List<Object?> get props => [];
}

class RideInitial extends RideState {
  const RideInitial();
}

typedef RideIdle = RideInitial;

class RideLoading extends RideState {
  const RideLoading();
}

class RideSearching extends RideState {
  final double price;

  const RideSearching({this.price = 2450.0});

  @override
  List<Object?> get props => [price];
}

class RideAccepted extends RideState {
  final String captainName;
  final String vehicleModel;
  final String vehiclePlate;
  final double captainRating;
  final String eta;

  const RideAccepted({
    required this.captainName,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.captainRating,
    required this.eta,
  });

  @override
  List<Object?> get props => [
        captainName,
        vehicleModel,
        vehiclePlate,
        captainRating,
        eta,
      ];
}

class RideInProgress extends RideState {
  final String etaToDestination;

  const RideInProgress({this.etaToDestination = '12 دقيقة'});

  @override
  List<Object?> get props => [etaToDestination];
}

class RideCompleted extends RideState {
  const RideCompleted();
}

class RideOptionsLoaded extends RideState {
  final String pickup;
  final String dropoff;
  final List<RideOption> options;
  final double distance;
  final int duration;
  final double fare;

  const RideOptionsLoaded({
    required this.pickup,
    required this.dropoff,
    required this.options,
    required this.distance,
    required this.duration,
    required this.fare,
  });

  @override
  List<Object?> get props => [pickup, dropoff, options, distance, duration, fare];
}

class RideBookingConfirmed extends RideState {
  final String pickup;
  final String dropoff;
  final RideOption selectedOption;
  final String captainName;
  final String captainPhone;
  final String vehicleModel;
  final String vehiclePlate;
  final double rating;
  final String status;
  final String? rideId;

  const RideBookingConfirmed({
    required this.pickup,
    required this.dropoff,
    required this.selectedOption,
    required this.captainName,
    required this.captainPhone,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.rating,
    required this.status,
    this.rideId,
  });

  RideBookingConfirmed copyWith({
    String? pickup,
    String? dropoff,
    RideOption? selectedOption,
    String? captainName,
    String? captainPhone,
    String? vehicleModel,
    String? vehiclePlate,
    double? rating,
    String? status,
    String? rideId,
  }) {
    return RideBookingConfirmed(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      selectedOption: selectedOption ?? this.selectedOption,
      captainName: captainName ?? this.captainName,
      captainPhone: captainPhone ?? this.captainPhone,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      rideId: rideId ?? this.rideId,
    );
  }

  @override
  List<Object?> get props => [
        pickup,
        dropoff,
        selectedOption,
        captainName,
        captainPhone,
        vehicleModel,
        vehiclePlate,
        rating,
        status,
        rideId,
      ];
}

class ParcelSubmitted extends RideState {
  final ParcelData data;
  final String trackingId;
  final double price;

  const ParcelSubmitted({
    required this.data,
    required this.trackingId,
    required this.price,
  });

  @override
  List<Object?> get props => [data, trackingId, price];
}

class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object?> get props => [message];
}

// ===========================================================================
// RIDE BLOC (Clean Architecture)
// ===========================================================================

class RideBloc extends Bloc<RideEvent, RideState> {
  final RequestRideUseCase requestRideUseCase;
  final CancelRideUseCase cancelRideUseCase;
  final SubmitParcelOrderUseCase submitParcelOrderUseCase;

  RideBloc({
    required this.requestRideUseCase,
    required this.cancelRideUseCase,
    required this.submitParcelOrderUseCase,
  }) : super(const RideInitial()) {
    on<CalculateSingleTripFare>(_onCalculateSingleTripFare);
    on<ConfirmUnifiedBooking>(_onConfirmUnifiedBooking);
    on<ConfirmBooking>(_onConfirmBooking);
    on<SubmitParcelOrder>(_onSubmitParcelOrder);
    on<CancelRideRequested>(_onCancelRideRequested);
    on<SimulateRideStep>(_onSimulateRideStep);
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
}
