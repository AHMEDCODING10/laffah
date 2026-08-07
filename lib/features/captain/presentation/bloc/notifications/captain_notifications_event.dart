import 'package:equatable/equatable.dart';

abstract class CaptainNotificationsEvent extends Equatable {
  const CaptainNotificationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationsAndRequests extends CaptainNotificationsEvent {}

class RefreshNotificationsAndRequests extends CaptainNotificationsEvent {}
