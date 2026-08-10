import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:laffah/core/services/pusher_service.dart';
import 'package:laffah/core/services/routing_service.dart';
import '../../../domain/usecases/toggle_captain_status_usecase.dart';
import '../../../domain/usecases/request_payout_usecase.dart';
import '../../../domain/usecases/fetch_bonus_data_usecase.dart';
import '../../../domain/usecases/update_location_usecase.dart';
import 'captain_event.dart';
import 'captain_state.dart';

typedef EmitFn = Emitter<CaptainState>;

class CaptainBloc extends Bloc<CaptainEvent, CaptainState> {
  final ToggleCaptainStatusUseCase toggleCaptainStatusUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;
  final FetchBonusDataUseCase fetchBonusDataUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  StreamSubscription<Position>? _positionSubscription;

  final RoutingService routingService;
  final PusherService pusherService;

  CaptainBloc({
    required this.toggleCaptainStatusUseCase,
    required this.requestPayoutUseCase,
    required this.fetchBonusDataUseCase,
    required this.updateLocationUseCase,
    required this.routingService,
    required this.pusherService,
  }) : super(const CaptainOffline()) {
    on<ToggleOnlineStatus>(_onToggleOnlineStatus);
    on<UpdateCaptainLocation>(_onUpdateCaptainLocation);
    on<AcceptTrip>(_onAcceptTrip);
    on<RejectTrip>(_onRejectTrip);
    on<UpdateTripProgressState>(_onUpdateTripProgressState);
    on<FetchBonusData>(_onFetchBonusData);
    on<RequestPayout>(_onRequestPayout);
    on<IncomingTripRequestReceived>(_onIncomingTripRequestReceived);
  }

  Future<void> _onToggleOnlineStatus(ToggleOnlineStatus event, EmitFn emit) async {
    // Get actual location from GPS Service before toggling
    double lat = 0.0;
    double lng = 0.0;
    
    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {
      // Fallback: Use Sanaa center coordinates if GPS unavailable
      lat = 15.3605;
      lng = 44.1852;
    }

    final result = await toggleCaptainStatusUseCase(
      isOnline: event.isOnline,
      lat: lat, 
      lng: lng,
    );

    result.fold(
      (failure) {
        emit(const CaptainOffline());
      },
      (status) {
        if (status.isOnline) {
          emit(const CaptainOnline());
          _startLocationTracking();
          // Connect to real Pusher WebSocket to receive live trip requests
          pusherService.connect(
            captainId: status.captainId ?? 'unknown',
            onTripRequest: (data) => add(IncomingTripRequestReceived(data)),
          );
        } else {
          emit(const CaptainOffline());
          _stopLocationTracking();
          pusherService.disconnect();
        }
      },
    );
  }


  void _onIncomingTripRequestReceived(IncomingTripRequestReceived event, EmitFn emit) {
    final d = event.data;
    emit(IncomingTripRequest(
      tripId: (d['trip_id'] ?? d['id'] ?? 'TRIP-789').toString(),
      passengerName: (d['passenger_name'] ?? 'راكب لَفَّة').toString(),
      passengerPhone: (d['passenger_phone'] ?? '770000000').toString(),
      passengerRating: (d['passenger_rating'] is num) ? (d['passenger_rating'] as num).toDouble() : 4.8,
      pickup: (d['pickup_address'] ?? d['pickup'] ?? 'شارع حدة، صنعاء').toString(),
      dropoff: (d['dropoff_address'] ?? d['dropoff'] ?? 'جامعة صنعاء، صنعاء').toString(),
      fare: (d['fare'] is num) ? (d['fare'] as num).toDouble() : 2500.0,
      distance: (d['distance'] ?? '3.5 كم').toString(),
      duration: (d['duration'] ?? '12 دقيقة').toString(),
    ));
  }

  void _startLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    ).listen((Position position) {
      add(UpdateCaptainLocation(
        captainId: 'captain-123', // Hardcoded for now, should be from AuthBloc/SecureStorage
        lat: position.latitude,
        lng: position.longitude,
        heading: position.heading,
      ));
    });
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _positionSubscription?.cancel();
    pusherService.disconnect();
    return super.close();
  }

  Future<void> _onUpdateCaptainLocation(UpdateCaptainLocation event, EmitFn emit) async {
    emit(CaptainLocationUpdated(
      position: LatLng(event.lat, event.lng),
      heading: event.heading,
    ));
    await updateLocationUseCase(
      captainId: event.captainId,
      lat: event.lat,
      lng: event.lng,
      heading: event.heading,
    );
  }

  Future<void> _onAcceptTrip(AcceptTrip event, EmitFn emit) async {
    final currentState = state;
    if (currentState is IncomingTripRequest) {
      // Get current location for simulation
      double currentLat = 15.3605; // Fallback to Sanaa center
      double currentLng = 44.1852;
      try {
        final pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
        );
        currentLat = pos.latitude;
        currentLng = pos.longitude;
      } catch (_) {}

      // Simulation: Pickup is slightly offset from captain, Dropoff is further away
      final pickupPos = LatLng(currentLat + 0.002, currentLng + 0.002);
      final dropoffPos = LatLng(currentLat - 0.015, currentLng - 0.015);

      final routeResult = await routingService.getRoute(pickupPos, dropoffPos);

      emit(TripAccepted(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        passengerPhone: currentState.passengerPhone,
        passengerRating: currentState.passengerRating,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        distance: routeResult?.distanceText ?? currentState.distance,
        duration: routeResult?.durationText ?? currentState.duration,
        tripProgress: 'accepted',
        routePoints: routeResult?.points ?? [pickupPos, dropoffPos],
      ));
    }
  }

  void _onRejectTrip(RejectTrip event, EmitFn emit) {
    if (state is IncomingTripRequest) {
      emit(const CaptainOnline());
    }
  }

  void _onUpdateTripProgressState(UpdateTripProgressState event, EmitFn emit) {
    final currentState = state;
    
    if (event.nextStatus == 'arrived' && currentState is TripAccepted) {
      emit(currentState.copyWith(tripProgress: 'arrived'));
    } 
    else if (event.nextStatus == 'started' && currentState is TripAccepted) {
      emit(TripInProgress(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        passengerPhone: currentState.passengerPhone,
        passengerRating: currentState.passengerRating,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        remainingDistance: '3.4 كم',
        remainingDuration: '10 دقائق',
      ));
    } 
    else if (event.nextStatus == 'completed' && currentState is TripInProgress) {
      emit(TripCompleted(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        totalDistance: '8.4 كم',
        totalDuration: '24 دقيقة',
        paymentMethod: 'نقداً',
      ));
    }
  }

  Future<void> _onFetchBonusData(FetchBonusData event, EmitFn emit) async {
    emit(const CaptainLoading());
    final result = await fetchBonusDataUseCase();
    result.fold(
      (failure) => emit(CaptainFailureState(failure.message)),
      (data) => emit(CaptainBonusDataLoaded(
        completedTrips: data['completed_trips'] ?? 0,
        targetTrips: data['target_trips'] ?? 10,
        bonusAmount: (data['bonus_amount'] ?? 0).toDouble(),
      )),
    );
  }

  Future<void> _onRequestPayout(RequestPayout event, EmitFn emit) async {
    emit(const CaptainLoading());
    final result = await requestPayoutUseCase(
      event.amount,
      event.method,
      event.accountDetails,
    );
    result.fold(
      (failure) => emit(CaptainFailureState(failure.message)),
      (_) => emit(const CaptainPayoutRequestSuccess()),
    );
  }

}

