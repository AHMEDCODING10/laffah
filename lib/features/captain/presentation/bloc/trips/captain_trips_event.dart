import 'package:equatable/equatable.dart';

abstract class CaptainTripsEvent extends Equatable {
  const CaptainTripsEvent();

  @override
  List<Object> get props => [];
}

class FetchCaptainTrips extends CaptainTripsEvent {
  final bool isRefresh;
  final String statusFilter;

  const FetchCaptainTrips({
    this.isRefresh = false,
    this.statusFilter = 'الكل',
  });

  @override
  List<Object> get props => [isRefresh, statusFilter];
}
