import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

@immutable
abstract class CaptainState {
  const CaptainState();
}

/// حالة تحديث موقع الكابتن في الوقت الفعلي (GPS)
class CaptainLocationUpdated extends CaptainState {
  final LatLng position;
  final double heading;

  const CaptainLocationUpdated({
    required this.position,
    this.heading = 0.0,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptainLocationUpdated &&
          runtimeType == other.runtimeType &&
          position == other.position;

  @override
  int get hashCode => position.hashCode;
}

/// Loading state for state transitions and action delays
class CaptainLoading extends CaptainState {
  const CaptainLoading();
}

/// Offline state of the captain (متصل / منقطع)
class CaptainOffline extends CaptainState {
  const CaptainOffline();
}

/// Online state of the captain, ready and waiting for requests
class CaptainOnline extends CaptainState {
  const CaptainOnline();
}

/// State when a new trip request is received (Screenshot 1)
class IncomingTripRequest extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;

  const IncomingTripRequest({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IncomingTripRequest &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          passengerName == other.passengerName &&
          passengerPhone == other.passengerPhone &&
          passengerRating == other.passengerRating &&
          pickup == other.pickup &&
          dropoff == other.dropoff &&
          fare == other.fare &&
          distance == other.distance &&
          duration == other.duration;

  @override
  int get hashCode =>
      tripId.hashCode ^
      passengerName.hashCode ^
      passengerPhone.hashCode ^
      passengerRating.hashCode ^
      pickup.hashCode ^
      dropoff.hashCode ^
      fare.hashCode ^
      distance.hashCode ^
      duration.hashCode;
}

/// State when captain accepts the trip but has not arrived or started it yet
class TripAccepted extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final String tripProgress; // 'accepted' or 'arrived'
  /// نقاط المسار من OSRM لعرضها على الخريطة
  final List<LatLng> routePoints;

  const TripAccepted({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.tripProgress,
    this.routePoints = const [],
  });

  TripAccepted copyWith({
    String? tripId,
    String? passengerName,
    String? passengerPhone,
    double? passengerRating,
    String? pickup,
    String? dropoff,
    double? fare,
    String? distance,
    String? duration,
    String? tripProgress,
    List<LatLng>? routePoints,
  }) {
    return TripAccepted(
      tripId: tripId ?? this.tripId,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      passengerRating: passengerRating ?? this.passengerRating,
      pickup: pickup ?? this.pickup,
      dropoff: dropoff ?? this.dropoff,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      duration: duration ?? this.duration,
      tripProgress: tripProgress ?? this.tripProgress,
      routePoints: routePoints ?? this.routePoints,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripAccepted &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          tripProgress == other.tripProgress;

  @override
  int get hashCode => tripId.hashCode ^ tripProgress.hashCode;
}

/// State when captain is actively driving the passenger to destination (Screenshot 2)
class TripInProgress extends CaptainState {
  final String tripId;
  final String passengerName;
  final String passengerPhone;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String remainingDistance;
  final String remainingDuration;

  const TripInProgress({
    required this.tripId,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.remainingDistance,
    required this.remainingDuration,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripInProgress &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          passengerName == other.passengerName &&
          passengerPhone == other.passengerPhone &&
          passengerRating == other.passengerRating &&
          pickup == other.pickup &&
          dropoff == other.dropoff &&
          fare == other.fare &&
          remainingDistance == other.remainingDistance &&
          remainingDuration == other.remainingDuration;

  @override
  int get hashCode =>
      tripId.hashCode ^
      passengerName.hashCode ^
      passengerPhone.hashCode ^
      passengerRating.hashCode ^
      pickup.hashCode ^
      dropoff.hashCode ^
      fare.hashCode ^
      remainingDistance.hashCode ^
      remainingDuration.hashCode;
}

/// State when the trip has successfully finished and showing summary (Screenshot 4)
class TripCompleted extends CaptainState {
  final String tripId;
  final String passengerName;
  final String pickup;
  final String dropoff;
  final double fare;
  final String totalDistance;
  final String totalDuration;
  final String paymentMethod; // e.g., AppLocalizations.of(context)!.capt_cash

  const TripCompleted({
    required this.tripId,
    required this.passengerName,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.totalDistance,
    required this.totalDuration,
    required this.paymentMethod,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripCompleted &&
          runtimeType == other.runtimeType &&
          tripId == other.tripId &&
          passengerName == other.passengerName &&
          pickup == other.pickup &&
          dropoff == other.dropoff &&
          fare == other.fare &&
          totalDistance == other.totalDistance &&
          totalDuration == other.totalDuration &&
          paymentMethod == other.paymentMethod;

  @override
  int get hashCode =>
      tripId.hashCode ^
      passengerName.hashCode ^
      pickup.hashCode ^
      dropoff.hashCode ^
      fare.hashCode ^
      totalDistance.hashCode ^
      totalDuration.hashCode ^
      paymentMethod.hashCode;
}

class CaptainBonusDataLoaded extends CaptainState {
  final int completedTrips;
  final int targetTrips;
  final double bonusAmount;

  const CaptainBonusDataLoaded({
    required this.completedTrips,
    required this.targetTrips,
    required this.bonusAmount,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptainBonusDataLoaded &&
          runtimeType == other.runtimeType &&
          completedTrips == other.completedTrips &&
          targetTrips == other.targetTrips &&
          bonusAmount == other.bonusAmount;

  @override
  int get hashCode =>
      completedTrips.hashCode ^ targetTrips.hashCode ^ bonusAmount.hashCode;
}

class CaptainPayoutRequestSuccess extends CaptainState {
  const CaptainPayoutRequestSuccess();
}

class CaptainFailureState extends CaptainState {
  final String message;
  const CaptainFailureState(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CaptainFailureState &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
