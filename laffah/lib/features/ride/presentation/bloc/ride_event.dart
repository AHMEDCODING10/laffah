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

class ResetRideState extends RideEvent {
  const ResetRideState();
}

class CalculateSingleTripFare extends RideEvent {
  final String pickup;
  final String dropoff;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final List<Map<String, dynamic>>? stops;

  const CalculateSingleTripFare({
    required this.pickup,
    required this.dropoff,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.stops,
  });

  @override
  List<Object?> get props => [pickup, dropoff, pickupLatitude, pickupLongitude, dropoffLatitude, dropoffLongitude];
}

class ConfirmUnifiedBooking extends RideEvent {
  final String pickup;
  final String dropoff;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final List<String> additionalDropoffs; // For Multiple Drop-offs
  final List<Map<String, dynamic>>? stops; // Structured stops with coords
  final double fare;
  final double distance;
  final int duration;
  final bool isScheduled; // For Scheduled Rides
  final DateTime? scheduledTime;

  const ConfirmUnifiedBooking({
    required this.pickup,
    required this.dropoff,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.additionalDropoffs = const [],
    this.stops,
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
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        additionalDropoffs,
        stops,
        fare,
        distance,
        duration,
        isScheduled,
        scheduledTime,
      ];
}

class ConfirmBooking extends RideEvent {
  final String pickup;
  final String dropoff;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final String rideType;

  const ConfirmBooking({
    required this.pickup,
    required this.dropoff,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    required this.rideType,
  });

  @override
  List<Object?> get props => [
        pickup,
        dropoff,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        rideType,
      ];
}


class SubmitParcelOrder extends RideEvent {
  final ParcelData data;

  const SubmitParcelOrder(this.data);

  @override
  List<Object?> get props => [data];
}

class CancelRideRequested extends RideEvent {
  final String? reason;
  final String? tripId; // For cancelling a specific trip by ID from history

  const CancelRideRequested({this.reason, this.tripId});

  @override
  List<Object?> get props => [reason, tripId];
}

/// Load trip history from the backend
class LoadTripHistoryEvent extends RideEvent {
  const LoadTripHistoryEvent();
}

class SubmitTripRating extends RideEvent {
  final String tripId;
  final double rating;
  final String? review;

  const SubmitTripRating({
    required this.tripId,
    required this.rating,
    this.review,
  });

  @override
  List<Object?> get props => [tripId, rating, review];
}

class SimulateRideStep extends RideEvent {
  final dynamic step;

  const SimulateRideStep({this.step});

  @override
  List<Object?> get props => [step];
}

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

/// Realtime trip status event from WebSocket (Pusher/Echo)
class TripStatusUpdatedFromWebSocket extends RideEvent {
  final Map<String, dynamic> data;

  const TripStatusUpdatedFromWebSocket(this.data);

  @override
  List<Object?> get props => [data];
}

/// Periodic smart polling trip status update event
class ActiveRidePolledStatusUpdated extends RideEvent {
  final String status;
  final String? captainName;
  final String? captainPhone;
  final String? vehicleModel;
  final String? vehiclePlate;
  final double rating;
  final String rideId;
  final RideOption option;
  final String pickup;
  final String dropoff;

  const ActiveRidePolledStatusUpdated({
    required this.status,
    this.captainName,
    this.captainPhone,
    this.vehicleModel,
    this.vehiclePlate,
    this.rating = 5.0,
    required this.rideId,
    required this.option,
    required this.pickup,
    required this.dropoff,
  });

  @override
  List<Object?> get props => [
        status,
        captainName,
        captainPhone,
        vehicleModel,
        vehiclePlate,
        rating,
        rideId,
        option,
        pickup,
        dropoff,
      ];
}

