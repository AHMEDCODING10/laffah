import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
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

  const TripHistoryLoaded(this.trips);

  @override
  List<Object?> get props => [trips];
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
