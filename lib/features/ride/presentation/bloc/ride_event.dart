import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'ride_bloc.dart'; // For ParcelData DTO

/// RideEvent — Base class for all events handled by RideBloc.
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
