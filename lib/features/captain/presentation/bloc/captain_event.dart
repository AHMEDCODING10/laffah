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

/// Event triggered automatically to simulate receiving a mock ride request
class TriggerMockRequest extends CaptainEvent {
  const TriggerMockRequest();
}
