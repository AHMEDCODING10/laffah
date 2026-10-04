import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:laffah/core/services/pusher_service.dart';
import 'package:laffah/core/services/routing_service.dart';
import 'package:laffah/core/services/captain_trip_alert_sound_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../core/network/network_info.dart';
import '../../../../../core/di/injection_container.dart' as di;
import '../../../domain/usecases/toggle_captain_status_usecase.dart';
import '../../../domain/usecases/respond_to_trip_usecase.dart';
import '../../../domain/usecases/update_trip_status_usecase.dart';
import '../../../domain/usecases/request_payout_usecase.dart';
import '../../../domain/usecases/fetch_bonus_data_usecase.dart';
import '../../../domain/usecases/update_location_usecase.dart';
import '../../../domain/usecases/get_captain_nearby_requests_usecase.dart';
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
  final GetCaptainNearbyRequestsUseCase getNearbyRequestsUseCase;
  final CaptainTripAlertSoundService alertSoundService;

  StreamSubscription<Position>? _positionSubscription;
  StreamSubscription<bool>? _networkSubscription;
  Timer? _smartPollingTimer;
  Timer? _tripRequestTimer;
  String _currentCaptainId = '';
  final Set<String> _dismissedTripIds = {};

  LatLng? _currentCaptainPosition;
  double _currentCaptainHeading = 0.0;

  LatLng? get currentCaptainPosition => _currentCaptainPosition;
  double get currentCaptainHeading => _currentCaptainHeading;

  final RoutingService routingService;
  final PusherService pusherService;

  CaptainBloc({
    required this.toggleCaptainStatusUseCase,
    required this.respondToTripUseCase,
    required this.updateTripStatusUseCase,
    required this.requestPayoutUseCase,
    required this.fetchBonusDataUseCase,
    required this.updateLocationUseCase,
    required this.getNearbyRequestsUseCase,
    required this.routingService,
    required this.pusherService,
    required this.alertSoundService,
  }) : super(const CaptainOffline()) {
    on<TripNoLongerAvailableReceived>(_onTripNoLongerAvailableReceived);
    on<ResetCaptainState>(_onResetCaptainState);

    _networkSubscription = di.sl<NetworkInfo>().isConnectedStream.listen((isConnected) {
      if (isConnected) {
        _syncPendingTripStatus();
      }
    });

    on<ToggleOnlineStatus>(_onToggleOnlineStatus);
    on<UpdateCaptainLocation>(_onUpdateCaptainLocation);
    on<AcceptTrip>(_onAcceptTrip);
    on<RejectTrip>(_onRejectTrip);
    on<UpdateTripProgressState>(_onUpdateTripProgressState);
    on<FetchBonusData>(_onFetchBonusData);
    on<RequestPayout>(_onRequestPayout);
    on<IncomingTripRequestReceived>(_onIncomingTripRequestReceived);
  }

    Future<void> _syncPendingTripStatus() async {
    final prefs = di.sl<SharedPreferences>();
    final pendingTripId = prefs.getString('pending_trip_id');
    final pendingStatus = prefs.getString('pending_trip_status');

    if (pendingTripId != null && pendingStatus != null) {
      debugPrint('?? [OfflineCatch] Re-syncing trip $pendingTripId to status $pendingStatus');
      final result = await updateTripStatusUseCase(tripId: pendingTripId, status: pendingStatus);
      result.fold(
        (failure) => debugPrint('? [OfflineCatch] Sync failed again: $failure.message'),
        (_) {
          debugPrint('? [OfflineCatch] Sync successful!');
          prefs.remove('pending_trip_id');
          prefs.remove('pending_trip_status');
        }
      );
    }
  }

  Future<void> _onToggleOnlineStatus(
      ToggleOnlineStatus event, EmitFn emit) async {
    // Get actual location from GPS Service before toggling
    double lat = 15.3605;
    double lng = 44.1852;

    try {
      final pos = await Geolocator.getCurrentPosition(
        locationSettings:
            const LocationSettings(accuracy: LocationAccuracy.high),
      ).timeout(const Duration(seconds: 3));
      lat = pos.latitude;
      lng = pos.longitude;
    } catch (_) {
      // Fallback: Use Sanaa center coordinates if GPS unavailable
      lat = 15.3605;
      lng = 44.1852;
    }

    if (lat < 12.0 || lat > 19.5 || lng < 41.5 || lng > 54.5) {
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
        emit(CaptainFailureState(failure.message));
        emit(const CaptainOffline());
        _stopSmartPolling();
      },
      (status) {
        if (status.isOnline) {
          final cid = status.captainId ?? 'captain';
          emit(const CaptainOnline());
          _startLocationTracking(cid);
          _pollNearbyRequests();
          _startSmartPolling();

          // Connect to real Pusher WebSocket to receive live trip requests
          pusherService.connect(
            captainId: cid,
            onTripRequest: (data) => add(IncomingTripRequestReceived(data)),
            onTripNoLongerAvailable: (data) {
              final tripId = (data['trip_id'] ?? data['id'] ?? '').toString();
              if (tripId.isNotEmpty) {
                add(TripNoLongerAvailableReceived(tripId));
              }
            },
          );
        } else {
          emit(const CaptainOffline());
          _stopLocationTracking();
          _stopSmartPolling();
          pusherService.disconnect();
        }
      },
    );
  }

  void _onTripNoLongerAvailableReceived(
      TripNoLongerAvailableReceived event, EmitFn emit) {
    _dismissedTripIds.add(event.tripId);
    if (state is IncomingTripRequest) {
      final currentTrip = state as IncomingTripRequest;
      if (currentTrip.tripId == event.tripId) {
        emit(const CaptainOnline());
      }
    } else if (state is TripAccepted) {
      final currentTrip = state as TripAccepted;
      if (currentTrip.tripId == event.tripId) {
        alertSoundService.playSimpleTripAlert();
        emit(const CaptainOnline());
      }
    } else if (state is TripInProgress) {
      final currentTrip = state as TripInProgress;
      if (currentTrip.tripId == event.tripId) {
        alertSoundService.playSimpleTripAlert();
        emit(const CaptainOnline());
      }
    }
  }

  void _onResetCaptainState(ResetCaptainState event, EmitFn emit) {
    _dismissedTripIds.clear();

    if (event.keepOnline) {
      // Maintain captain online status and resume searching for new requests immediately
      emit(const CaptainOnline());
      if (_currentCaptainId.isNotEmpty) {
        _startLocationTracking(_currentCaptainId);
        pusherService.connect(
          captainId: _currentCaptainId,
          onTripRequest: (data) => add(IncomingTripRequestReceived(data)),
          onTripNoLongerAvailable: (data) {
            final tripId = (data['trip_id'] ?? data['id'] ?? '').toString();
            if (tripId.isNotEmpty) {
              add(TripNoLongerAvailableReceived(tripId));
            }
          },
        );
      }
      _pollNearbyRequests(); // Do one initial fetch just in case
      _startSmartPolling();
    } else {
      _stopSmartPolling();
      _stopLocationTracking();
      pusherService.disconnect();
      emit(const CaptainOffline());
    }
  }

  void _startSmartPolling() {
    _smartPollingTimer?.cancel();
    _smartPollingTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
      _pollNearbyRequests();
    });
  }

  void _stopSmartPolling() {
    _smartPollingTimer?.cancel();
    _smartPollingTimer = null;
  }

  Future<void> _pollNearbyRequests() async {
    // Only poll when captain is actively online and not in an active trip
    if (state is! CaptainOnline) return;

    final result = await getNearbyRequestsUseCase();
    result.fold(
      (failure) => null,
      (requests) {
        if (state is! CaptainOnline) return;

        // Find the first pending request that hasn't been dismissed by captain
        final validRequests = requests.where((r) => !_dismissedTripIds.contains(r.id)).toList();
        if (validRequests.isNotEmpty) {
          final req = validRequests.first;
          add(IncomingTripRequestReceived({
            'trip_id': req.id,
            'passenger_name': req.passengerName,
            'passenger_phone': req.passengerPhone,
            'receiver_name': req.receiverName,
            'receiver_phone': req.receiverPhone,
            'passenger_rating': req.passengerRating,
            'pickup_address': req.pickup,
            'dropoff_address': req.dropoff,
            'fare': req.grossFare > 0 ? req.grossFare : (double.tryParse(req.price) ?? 870.0),
            'distance': req.distance,
            'duration': req.duration,
            'timeTag': req.timeTag,
            'is_parcel': req.isParcel,
            'parcel_type': req.parcelType ?? (req.isParcel ? 'طرد' : null),
            'size': req.size ?? 'متوسط',
            'tracking_code': req.trackingCode ?? req.id,
            'pickupLat': req.pickupLat,
            'pickupLng': req.pickupLng,
            'dropoffLat': req.dropoffLat,
            'dropoffLng': req.dropoffLng,
          }));
        }
      },
    );
  }

  void _onIncomingTripRequestReceived(
      IncomingTripRequestReceived event, EmitFn emit) {
    if (state is! CaptainOnline && state is! IncomingTripRequest) return;

    final d = event.data;
    if (d.isEmpty) return;

    final rawTripId = d['trip_id'] ?? d['id'] ?? d['tripId'];
    if (rawTripId == null ||
        rawTripId.toString().trim().isEmpty ||
        rawTripId.toString() == 'TRIP-789') {
      return;
    }
    final tripId = rawTripId.toString();

    // Check if dismissed
    if (_dismissedTripIds.contains(tripId)) return;

    // Cancel any previous trip request timer
    _tripRequestTimer?.cancel();
    _tripRequestTimer = null;

    // Play subtle chime / alert sound once
    alertSoundService.playSimpleTripAlert();

    final isParcel = d['is_parcel'] == true ||
        d['isParcel'] == true ||
        d['type'] == 'delivery';
    final parcelType = d['parcel_type']?.toString() ??
        d['notes']?.toString() ??
        (isParcel ? 'طرد' : null);

    final String pName = (d['passenger_name'] ??
            d['passengerName'] ??
            d['sender_name'] ??
            'عميل')
        .toString();
    final String pPhone = (d['passenger_phone'] ??
            d['passengerPhone'] ??
            d['sender_phone'] ??
            '')
        .toString();
    final String rName = (d['receiver_name'] ??
            d['receiverName'] ??
            'المستلم')
        .toString();
    final String rPhone = (d['receiver_phone'] ??
            d['receiverPhone'] ??
            '')
        .toString();
    final String pickup = (d['pickup_address'] ??
            d['pickup'] ??
            d['pickup_location'] ??
            'موقع الاستلام')
        .toString();
    final String dropoff = (d['dropoff_address'] ??
            d['dropoff'] ??
            d['dropoff_location'] ??
            'موقع التسليم')
        .toString();
    final double fare = (d['fare'] is num)
        ? (d['fare'] as num).toDouble()
        : ((d['grossFare'] is num)
            ? (d['grossFare'] as num).toDouble()
            : (double.tryParse(d['price']?.toString() ?? '') ?? 0.0));

    emit(IncomingTripRequest(
      tripId: tripId,
      passengerName: pName,
      passengerPhone: pPhone,
      receiverName: rName,
      receiverPhone: rPhone,
      passengerRating: (d['passenger_rating'] is num)
          ? (d['passenger_rating'] as num).toDouble()
          : ((d['passengerRating'] is num)
              ? (d['passengerRating'] as num).toDouble()
              : 5.0),
      pickup: pickup,
      dropoff: dropoff,
      fare: fare,
      distance: (d['distance'] ?? '2.5 كم').toString(),
      duration: (d['duration'] ?? '6 د').toString(),
      timeTag: (d['timeTag'] ?? 'منذ ثواني').toString(),
      isParcel: isParcel,
      parcelType: parcelType,
      size: d['size']?.toString() ?? 'متوسط',
      pickupLat: d['pickupLat'] != null ? (d['pickupLat'] as num).toDouble() : null,
      pickupLng: d['pickupLng'] != null ? (d['pickupLng'] as num).toDouble() : null,
      dropoffLat: d['dropoffLat'] != null ? (d['dropoffLat'] as num).toDouble() : null,
      dropoffLng: d['dropoffLng'] != null ? (d['dropoffLng'] as num).toDouble() : null,
      paymentMethod: (d['payment_method'] ?? d['paymentMethod'] ?? 'cash').toString(),
    ));
  }

  void _startLocationTracking(String captainId) {
    _currentCaptainId = captainId;
    _positionSubscription?.cancel();

    late LocationSettings locationSettings;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationText: "كابتن لَفَّة متصل — جاري تتبع الموقع لاستقبال المشاوير",
          notificationTitle: "لَفَّة — خدمة الكابتن النشطة",
          notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
          enableWakeLock: true,
        ),
      );
    } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation,
        distanceFilter: 30,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 30,
      );
    }

    try {
      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          add(UpdateCaptainLocation(
            captainId: _currentCaptainId,
            lat: position.latitude,
            lng: position.longitude,
            heading: position.heading,
          ));
        },
        onError: (error) {
          debugPrint('ℹ️ [CaptainLocation] GPS stream note (handled gracefully): $error');
        },
      );
    } catch (e) {
      debugPrint('ℹ️ [CaptainLocation] getPositionStream error: $e');
    }
  }

  void _stopLocationTracking() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
  }

  @override
  Future<void> close() {
    _stopSmartPolling();
    _positionSubscription?.cancel();
    _networkSubscription?.cancel();
    pusherService.disconnect();
    return super.close();
  }

  Future<void> _onUpdateCaptainLocation(
      UpdateCaptainLocation event, EmitFn emit) async {
    _currentCaptainPosition = LatLng(event.lat, event.lng);
    _currentCaptainHeading = event.heading;

    // Push coordinates to the backend server
    await updateLocationUseCase(
      captainId: event.captainId,
      lat: event.lat,
      lng: event.lng,
      heading: event.heading,
    );

    // CRITICAL FIX: NEVER overwrite active modal / trip workflow states with a location ping!
    // If captain is in IncomingTripRequest, TripAccepted, TripInProgress, or CaptainLoading,
    // preserve their active screen state so the dialog never disappears!
    if (state is IncomingTripRequest ||
        state is TripAccepted ||
        state is TripInProgress ||
        state is CaptainLoading) {
      return;
    }

    emit(CaptainLocationUpdated(
      position: _currentCaptainPosition!,
      heading: _currentCaptainHeading,
    ));
  }

  Future<void> _onAcceptTrip(AcceptTrip event, EmitFn emit) async {
    if (state is IncomingTripRequest) {
      final currentState = state as IncomingTripRequest;
      _tripRequestTimer?.cancel();
      
      emit(const CaptainLoading());

      final result = await respondToTripUseCase(
        tripId: currentState.tripId,
        accept: true,
        isParcel: currentState.isParcel,
      );

      await result.fold(
        (failure) async {
          // If rejected by server (e.g. 409 Conflict - trip already accepted by another captain or cancelled)
          _dismissedTripIds.add(currentState.tripId);
          emit(CaptainFailureState(failure.message));
          emit(const CaptainOnline());
        },
        (_) async {
          // Success: proceed to active accepted trip
          _stopSmartPolling();
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

          final pickupPos = currentState.pickupLat != null && currentState.pickupLng != null
              ? LatLng(currentState.pickupLat!, currentState.pickupLng!)
              : LatLng(currentLat + 0.002, currentLng + 0.002);
          final dropoffPos = currentState.dropoffLat != null && currentState.dropoffLng != null
              ? LatLng(currentState.dropoffLat!, currentState.dropoffLng!)
              : LatLng(currentLat - 0.015, currentLng - 0.015);

          final routeResult = await routingService.getRoute(pickupPos, dropoffPos);

          emit(TripAccepted(
            tripId: currentState.tripId,
            passengerName: currentState.passengerName,
            passengerPhone: currentState.passengerPhone,
            receiverName: currentState.receiverName,
            receiverPhone: currentState.receiverPhone,
            passengerRating: currentState.passengerRating,
            pickup: currentState.pickup,
            dropoff: currentState.dropoff,
            fare: currentState.fare,
            distance: routeResult?.distanceText ?? currentState.distance,
            duration: routeResult?.durationText ?? currentState.duration,
            tripProgress: 'accepted',
            routePoints: routeResult?.points ?? [pickupPos, dropoffPos],
            isParcel: currentState.isParcel,
            parcelType: currentState.parcelType,
            size: currentState.size,
            trackingCode: currentState.tripId,
            paymentMethod: currentState.paymentMethod,
          ));
        },
      );
    }
  }

  Future<void> _onRejectTrip(RejectTrip event, EmitFn emit) async {
    if (state is IncomingTripRequest) {
      final req = state as IncomingTripRequest;
      
      _dismissedTripIds.add(req.tripId);
      _tripRequestTimer?.cancel();
      
      // Notify backend that we rejected this
      respondToTripUseCase(
        tripId: req.tripId, 
        accept: false, 
        isParcel: req.isParcel
      );
      
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
    } else if ((event.nextStatus == 'started' || event.nextStatus == 'in_transit') &&
        currentState is TripAccepted) {
      emit(TripInProgress(
        tripId: currentState.tripId,
        passengerName: currentState.passengerName,
        passengerPhone: currentState.passengerPhone,
        passengerRating: currentState.passengerRating,
        pickup: currentState.pickup,
        dropoff: currentState.dropoff,
        fare: currentState.fare,
        remainingDistance: currentState.distance,
        remainingDuration: currentState.duration,
      ));
    } else if (event.nextStatus == 'completed') {
      final tripId = (currentState is TripInProgress)
          ? currentState.tripId
          : (currentState is TripAccepted ? currentState.tripId : (event.tripId ?? ''));
      final pName = (currentState is TripInProgress)
          ? currentState.passengerName
          : (currentState is TripAccepted ? currentState.passengerName : 'الراكب');
      final pickup = (currentState is TripInProgress)
          ? currentState.pickup
          : (currentState is TripAccepted ? currentState.pickup : '');
      final dropoff = (currentState is TripInProgress)
          ? currentState.dropoff
          : (currentState is TripAccepted ? currentState.dropoff : '');
      final fare = (currentState is TripInProgress)
          ? currentState.fare
          : (currentState is TripAccepted ? currentState.fare : 1000.0);
      final distance = (currentState is TripInProgress)
          ? currentState.remainingDistance
          : (currentState is TripAccepted ? currentState.distance : 'غير معروف');
      final duration = (currentState is TripInProgress)
          ? currentState.remainingDuration
          : (currentState is TripAccepted ? currentState.duration : 'غير معروف');

      emit(TripCompleted(
        tripId: tripId,
        passengerName: pName,
        pickup: pickup,
        dropoff: dropoff,
        fare: fare,
        totalDistance: distance,
        totalDuration: duration,
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

