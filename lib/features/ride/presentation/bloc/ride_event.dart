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
<<<<<<< HEAD
  final double fare;
  final double distance;
  final int duration;
=======
  final List<String> additionalDropoffs; // For Multiple Drop-offs
  final double fare;
  final double distance;
  final int duration;
  final bool isScheduled; // For Scheduled Rides
  final DateTime? scheduledTime;
>>>>>>> origin/admin-ahmed

  const ConfirmUnifiedBooking({
    required this.pickup,
    required this.dropoff,
<<<<<<< HEAD
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  List<Object?> get props => [pickup, dropoff, fare, distance, duration];
=======
    this.additionalDropoffs = const [],
    required this.fare,
    required this.distance,
    required this.duration,
    this.isScheduled = false,
    this.scheduledTime,
  });

  @override
  List<Object?> get props => [
        pickup,
        dropoff,
        additionalDropoffs,
        fare,
        distance,
        duration,
        isScheduled,
        scheduledTime,
      ];
>>>>>>> origin/admin-ahmed
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
<<<<<<< HEAD

  const CancelRideRequested({this.reason});

  @override
  List<Object?> get props => [reason];
=======
  final String? tripId; // For cancelling a specific trip by ID from history

  const CancelRideRequested({this.reason, this.tripId});

  @override
  List<Object?> get props => [reason, tripId];
}

/// Load trip history from the backend
class LoadTripHistoryEvent extends RideEvent {
  const LoadTripHistoryEvent();
>>>>>>> origin/admin-ahmed
}

class SimulateRideStep extends RideEvent {
  final dynamic step;

  const SimulateRideStep({this.step});

  @override
  List<Object?> get props => [step];
}
<<<<<<< HEAD
=======

class ScheduleRide extends RideEvent {
  final DateTime date;
  final String time;

  const ScheduleRide({
    required this.date,
    required this.time,
  });

  @override
  List<Object?> get props => [date, time];
}
>>>>>>> origin/admin-ahmed
