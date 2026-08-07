import 'package:flutter/foundation.dart';

@immutable
abstract class CaptainEvent {
  const CaptainEvent();
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
/// Progress levels: 'arrived' (وصلت), 'started' (ابدأ الرحلة), 'completed' (إنهاء الرحلة)
class UpdateTripProgressState extends CaptainEvent {
  final String nextStatus; // 'arrived', 'started', 'completed'
  const UpdateTripProgressState(this.nextStatus);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateTripProgressState &&
          runtimeType == other.runtimeType &&
          nextStatus == other.nextStatus;

  @override
  int get hashCode => nextStatus.hashCode;
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

