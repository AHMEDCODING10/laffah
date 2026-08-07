import 'package:equatable/equatable.dart';
import '../../../domain/entities/captain_notification_entity.dart';
import '../../../domain/entities/captain_trip_request_entity.dart';

abstract class CaptainNotificationsState extends Equatable {
  const CaptainNotificationsState();

  @override
  List<Object?> get props => [];
}

class CaptainNotificationsInitial extends CaptainNotificationsState {}

class CaptainNotificationsLoading extends CaptainNotificationsState {}

class CaptainNotificationsLoaded extends CaptainNotificationsState {
  final List<CaptainNotificationEntity> notifications;
  final List<CaptainTripRequestEntity> nearbyRequests;

  const CaptainNotificationsLoaded({
    required this.notifications,
    required this.nearbyRequests,
  });

  @override
  List<Object?> get props => [notifications, nearbyRequests];
}

class CaptainNotificationsError extends CaptainNotificationsState {
  final String message;

  const CaptainNotificationsError({required this.message});

  @override
  List<Object?> get props => [message];
}
