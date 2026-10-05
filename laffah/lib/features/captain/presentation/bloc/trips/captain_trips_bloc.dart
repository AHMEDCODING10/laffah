import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_captain_trips_usecase.dart';
import '../../../domain/entities/captain_trip_entity.dart';
import 'captain_trips_event.dart';
import 'captain_trips_state.dart';

class CaptainTripsBloc extends Bloc<CaptainTripsEvent, CaptainTripsState> {
  final GetCaptainTripsUseCase getCaptainTripsUseCase;
  int _currentPage = 1;

  CaptainTripsBloc({required this.getCaptainTripsUseCase})
      : super(CaptainTripsInitial()) {
    on<FetchCaptainTrips>(_onFetchCaptainTrips);
  }

  Future<void> _onFetchCaptainTrips(
      FetchCaptainTrips event, Emitter<CaptainTripsState> emit) async {
    final currentState = state;

    List<CaptainTripEntity> oldTrips = [];
    if (currentState is CaptainTripsLoaded &&
        !event.isRefresh &&
        currentState.statusFilter == event.statusFilter) {
      oldTrips = currentState.trips;
    } else if (currentState is CaptainTripsLoaded && event.isSilent) {
      oldTrips = currentState.trips;
    }

    if (event.isRefresh ||
        (currentState is CaptainTripsLoaded &&
            currentState.statusFilter != event.statusFilter)) {
      _currentPage = 1;
      if (!event.isSilent && currentState is! CaptainTripsLoaded) {
        emit(const CaptainTripsLoading([], isFirstFetch: true));
      }
    } else {
      if (!event.isSilent) {
        emit(CaptainTripsLoading(oldTrips, isFirstFetch: oldTrips.isEmpty));
      }
    }

    final result = await getCaptainTripsUseCase(
      page: _currentPage,
      statusFilter: event.statusFilter,
    );

    result.fold(
      (failure) {
        if (state is! CaptainTripsLoaded) {
          emit(CaptainTripsError(failure.message));
        }
      },
      (newTrips) {
        _currentPage++;

        final trips = (event.isRefresh ||
                (currentState is CaptainTripsLoaded &&
                    currentState.statusFilter != event.statusFilter))
            ? newTrips
            : oldTrips + newTrips;

        emit(CaptainTripsLoaded(
          trips: trips,
          hasReachedMax: newTrips.isEmpty,
          statusFilter: event.statusFilter,
        ));
      },
    );
  }
}
