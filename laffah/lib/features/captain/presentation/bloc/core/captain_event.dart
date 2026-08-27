import 'package:flutter/foundation.dart';

@immutable
abstract class CaptainEvent {
  const CaptainEvent();
}

class ResetCaptainState extends CaptainEvent {
  final bool keepOnline;
  const ResetCaptainState({this.keepOnline = true});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResetCaptainState &&
          runtimeType == other.runtimeType &&
          keepOnline == other.keepOnline;

  @override
  int get hashCode => keepOnline.hashCode;
}

/// Event to toggle online/offline status
class ToggleOnlineStatus extends CaptainEvent {
  final bool isOnline;
  const ToggleOnlineStatus(this.isOnline);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToggleOnlineStatus &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline;

  @override
  int get hashCode => isOnline.hashCode;
}

/// Event when captain accepts the trip request
class FetchBonusData extends CaptainEvent {
  const FetchBonusData();

  List<Object?> get props => [];
}

class RequestPayout extends CaptainEvent {
  final double amount;
  final String method;
  final String accountDetails;

  const RequestPayout({
    required this.amount,
    required this.method,
    required this.accountDetails,
  });

  List<Object?> get props => [amount, method, accountDetails];
}

class AcceptTrip extends CaptainEvent {
  const AcceptTrip();
}

/// Event when captain rejects the trip request
class RejectTrip extends CaptainEvent {
  const RejectTrip();
}

/// Event to transition the current trip progress
/// Progress levels: 'arrived' (وصلت), 'started'/'in_transit' (ابدأ الرحلة), 'completed' (إنهاء الرحلة)
class UpdateTripProgressState extends CaptainEvent {
  final String nextStatus; // 'arrived', 'started', 'completed'
  final String? tripId;

  const UpdateTripProgressState(this.nextStatus, {this.tripId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateTripProgressState &&
          runtimeType == other.runtimeType &&
          nextStatus == other.nextStatus &&
          tripId == other.tripId;

  @override
  int get hashCode => nextStatus.hashCode ^ tripId.hashCode;
}


/// Event to update the captain's location
class UpdateCaptainLocation extends CaptainEvent {
  final String captainId;
  final double lat;
  final double lng;
  final double heading;

  const UpdateCaptainLocation({
    required this.captainId,
    required this.lat,
    required this.lng,
    required this.heading,
  });

  List<Object?> get props => [captainId, lat, lng, heading];
}

/// Event triggered when a real-time trip request payload arrives via WebSocket/Pusher
class IncomingTripRequestReceived extends CaptainEvent {
  final Map<String, dynamic> data;

  const IncomingTripRequestReceived(this.data);
}

/// Event triggered when a trip is taken by another captain, cancelled, or expired
class TripNoLongerAvailableReceived extends CaptainEvent {
  final String tripId;

  const TripNoLongerAvailableReceived(this.tripId);
}

