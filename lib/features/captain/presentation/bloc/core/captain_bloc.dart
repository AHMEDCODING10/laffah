import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:laffah/core/services/pusher_service.dart';
import 'package:laffah/core/services/routing_service.dart';
import '../../../domain/usecases/toggle_captain_status_usecase.dart';
import '../../../domain/usecases/respond_to_trip_usecase.dart';
import '../../../domain/usecases/update_trip_status_usecase.dart';
import '../../../domain/usecases/request_payout_usecase.dart';
import '../../../domain/usecases/fetch_bonus_data_usecase.dart';
import '../../../domain/usecases/update_location_usecase.dart';
import 'captain_event.dart';
import 'captain_state.dart';

typedef EmitFn = Emitter<CaptainState>;

class CaptainBloc extends Bloc<CaptainEvent, CaptainState> {
  final ToggleCaptainStatusUseCase toggleCaptainStatusUseCase;
  final RespondToTripUseCase respondToTripUseCase;
  final UpdateTripStatusUseCase updateTripStatusUseCase;
  final RequestPayoutUseCase requestPayoutUseCase;
  final FetchBonusDataUseCase fetchBonusDataUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  StreamSubscription<Position>? _positionSubscription;
  String _currentCaptainId = '';

  final RoutingService routingService;
  final PusherService pusherService;

  CaptainBloc({
    required this.toggleCaptainStatusUseCase,
    required this.respondToTripUseCase,
    required this.updateTripStatusUseCase,
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

  Future<void> _onToggleOnlineStatus(
      ToggleOnlineStatus event, EmitFn emit) async {
    // Get actual location from GPS Service before toggling
    double lat = 0.0;
    double lng = 0.0;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
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
          final cid = status.captainId ?? 'captain';
          emit(const CaptainOnline());
          _startLocationTracking(cid);
          // Connect to real Pusher WebSocket to receive live trip requests
          pusherService.connect(
            captainId: cid,
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

  void _onIncomingTripRequestReceived(
      IncomingTripRequestReceived event, EmitFn emit) {
    final d = event.data;
    emit(IncomingTripRequest(
      tripId: (d['trip_id'] ?? d['id'] ?? 'TRIP-789').toString(),
      passengerName: (d['passenger_name'] ?? 'راكب لَفَّة').toString(),
      passengerPhone: (d['passenger_phone'] ?? '770000000').toString(),
      passengerRating: (d['passenger_rating'] is num)
          ? (d['passenger_rating'] as num).toDouble()
          : 4.8,
      pickup:
          (d['pickup_address'] ?? d['pickup'] ?? 'شارع حدة، صنعاء').toString(),
      dropoff: (d['dropoff_address'] ?? d['dropoff'] ?? 'جامعة صنعاء، صنعاء')
          .toString(),
      fare: (d['fare'] is num) ? (d['fare'] as num).toDouble() : 2500.0,
      distance: (d['distance'] ?? '3.5 كم').toString(),
      duration: (d['duration'] ?? '12 دقيقة').toString(),
    ));
  }

  void _startLocationTracking(String captainId) {
    _currentCaptainId = captainId;
    _positionSubscription?.cancel();

    late LocationSettings locationSettings;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 5),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "كابتن لَفَّة متصل — جاري تتبع الموقع لاستقبال المشاوير",
          notificationTitle: "لَفَّة — خدمة الكابتن النشطة",
          enableWakeLock: true,
        ),
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 10,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
    }

    _positionSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      add(UpdateCaptainLocation(
        captainId: _currentCaptainId,
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

  Future<void> _onUpdateCaptainLocation(
      UpdateCaptainLocation event, EmitFn emit) async {
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
      final tripId = currentState.tripId;
      final result = await respondToTripUseCase(
        tripId: tripId,
        accept: true,
      );

      await result.fold(
        (failure) async {
          // If rejected by server (e.g. 409 Conflict - trip already accepted by another captain)
          emit(const CaptainOnline());
        },
        (_) async {
          // Success: proceed to active accepted trip
          double currentLat = 15.3605; // Fallback to Sanaa center
          double currentLng = 44.1852;
          try {
            final pos = await Geolocator.getCurrentPosition(
              locationSettings:
                  const LocationSettings(accuracy: LocationAccuracy.high),
            );
            currentLat = pos.latitude;
            currentLng = pos.longitude;
          } catch (_) {}

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
        },
      );
    }
  }

  Future<void> _onRejectTrip(RejectTrip event, EmitFn emit) async {
    if (state is IncomingTripRequest) {
      final tripId = (state as IncomingTripRequest).tripId;
      respondToTripUseCase(tripId: tripId, accept: false);
      emit(const CaptainOnline());
    }
  }


  Future<void> _onUpdateTripProgressState(
      UpdateTripProgressState event, EmitFn emit) async {
    final currentState = state;

    final targetTripId = event.tripId ??
        (currentState is TripAccepted
            ? currentState.tripId
            : (currentState is TripInProgress ? currentState.tripId : null));

    final backendStatus = event.nextStatus == 'started' ? 'in_transit' : event.nextStatus;

    if (targetTripId != null && targetTripId.isNotEmpty) {
      // Broadcast and update status on the backend server
      await updateTripStatusUseCase(tripId: targetTripId, status: backendStatus);
    }

    if (event.nextStatus == 'arrived' && currentState is TripAccepted) {
      emit(currentState.copyWith(tripProgress: 'arrived'));
    } else if (event.nextStatus == 'started' && currentState is TripAccepted) {
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
    } else if (event.nextStatus == 'completed' &&
        currentState is TripInProgress) {
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
        completedTrips: data['completed_trips'] as int? ??
            data['completed_today'] as int? ??
            data['completedToday'] as int? ??
            data['completedTripsToday'] as int? ??
            0,
        targetTrips: data['target_trips'] as int? ??
            data['daily_target'] as int? ??
            data['dailyTarget'] as int? ??
            10,
        bonusAmount: (data['bonus_amount'] as num?)?.toDouble() ??
            (data['bonusAmount'] as num?)?.toDouble() ??
            2500.0,
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
