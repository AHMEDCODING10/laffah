import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:collection/collection.dart';
import 'ride_bloc.dart'; // For ParcelData and RideOption DTOs

/// RideState — Base class for all states emitted by RideBloc.
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
  final String tripId;
  final String? captainId;
  final String captainName;
  final String captainPhone;
  final String vehicleModel;
  final String vehiclePlate;
  final double captainRating;
  final String eta;

  const RideAccepted({
    this.tripId = '',
    this.captainId,
    required this.captainName,
    this.captainPhone = '',
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.captainRating,
    required this.eta,
  });

  @override
  List<Object?> get props => [
        tripId,
        captainId,
        captainName,
        captainPhone,
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
  final int nearbyCaptainsCount;

  const RideOptionsLoaded({
    required this.pickup,
    required this.dropoff,
    required this.options,
    required this.distance,
    required this.duration,
    required this.fare,
    this.nearbyCaptainsCount = 0,
  });

  @override
  List<Object?> get props =>
      [pickup, dropoff, options, distance, duration, fare, nearbyCaptainsCount];
}

class RideBookingConfirmed extends RideState {
  final String pickup;
  final String dropoff;
  final RideOption selectedOption;
  final String? captainId;
  final String captainName;
  final String captainPhone;
  final String vehicleModel;
  final String vehiclePlate;
  final double rating;
  final String status;
  final String? rideId;
  final String? distance;
  final String? duration;
  final String? paymentMethod;
  final int nearbyCaptainsCount;

  const RideBookingConfirmed({
    required this.pickup,
    required this.dropoff,
    required this.selectedOption,
    this.captainId,
    required this.captainName,
    required this.captainPhone,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.rating,
    required this.status,
    this.rideId,
    this.distance,
    this.duration,
    this.paymentMethod,
    this.nearbyCaptainsCount = 0,
  });

  RideBookingConfirmed copyWith({
    String? pickup,
    String? dropoff,
    RideOption? selectedOption,
    String? captainId,
    String? captainName,
    String? captainPhone,
    String? vehicleModel,
    String? vehiclePlate,
    double? rating,
    String? status,
    String? rideId,
    String? distance,
    String? duration,
    String? paymentMethod,
    int? nearbyCaptainsCount,
  }) {
    return RideBookingConfirmed(
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      selectedOption: selectedOption ?? this.selectedOption,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
      captainPhone: captainPhone ?? this.captainPhone,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      rating: rating ?? this.rating,
      status: status ?? this.status,
      rideId: rideId ?? this.rideId,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      nearbyCaptainsCount: nearbyCaptainsCount ?? this.nearbyCaptainsCount,
    );
  }

  @override
  List<Object?> get props => [
        pickup,
        dropoff,
        selectedOption,
        captainId,
        captainName,
        captainPhone,
        vehicleModel,
        vehiclePlate,
        rating,
        status,
        rideId,
        distance,
        duration,
        paymentMethod,
        nearbyCaptainsCount,
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

class ParcelOrderSubmitted extends RideState {
  final ParcelData data;

  const ParcelOrderSubmitted(this.data);

  @override
  List<Object?> get props => [data];
}

class RideScheduledSuccess extends RideState {
  const RideScheduledSuccess();
}

// ============================================================
// Trip History States
// ============================================================
class TripHistoryLoading extends RideState {
  const TripHistoryLoading();
}

class TripHistoryLoaded extends RideState {
  final List<Map<String, dynamic>> trips;
  final int timestamp;

  TripHistoryLoaded(this.trips, [int? timestamp])
      : timestamp = timestamp ?? DateTime.now().millisecondsSinceEpoch;

  @override
  List<Object?> get props => [const DeepCollectionEquality().hash(trips), timestamp];
}

class TripHistoryError extends RideState {
  final String message;

  const TripHistoryError(this.message);

  @override
  List<Object?> get props => [message];
}

class RideError extends RideState {
  final String message;

  const RideError(this.message);

  @override
  List<Object?> get props => [message];
}
