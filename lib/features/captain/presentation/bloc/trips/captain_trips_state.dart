import 'package:equatable/equatable.dart';
import '../../../domain/entities/captain_trip_entity.dart';

abstract class CaptainTripsState extends Equatable {
  const CaptainTripsState();

  @override
  List<Object?> get props => [];
}

class CaptainTripsInitial extends CaptainTripsState {}

class CaptainTripsLoading extends CaptainTripsState {
  final List<CaptainTripEntity> oldTrips;
  final bool isFirstFetch;

  const CaptainTripsLoading(this.oldTrips, {this.isFirstFetch = false});

  @override
  List<Object?> get props => [oldTrips, isFirstFetch];
}

class CaptainTripsLoaded extends CaptainTripsState {
  final List<CaptainTripEntity> trips;
  final bool hasReachedMax;
  final String statusFilter;

  const CaptainTripsLoaded({
    required this.trips,
    this.hasReachedMax = false,
    this.statusFilter = 'الكل',
  });

  @override
  List<Object?> get props => [trips, hasReachedMax, statusFilter];
}

class CaptainTripsError extends CaptainTripsState {
  final String message;

  const CaptainTripsError(this.message);

  @override
  List<Object?> get props => [message];
}
