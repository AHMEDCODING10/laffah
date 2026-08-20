import 'dart:convert';
import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/app_env.dart';

/// Centralized Real-time WebSocket Service for Laffah.
/// Manages subscriptions for:
/// 1. Available Trips for Online Captains (`trips.available`)
/// 2. Active Trip Status Updates (`trip.{id}`)
/// 3. Live Captain Location Tracking (`captain-location.{captainId}`)
class EchoService {
  static final EchoService _instance = EchoService._internal();
  factory EchoService() => _instance;
  EchoService._internal();

  Echo? _echo;
  bool _isInitializing = false;
  bool _isConnected = false;

  Echo? get echo => _echo;
  bool get isConnected => _isConnected;

  /// Initialize Pusher / Laravel Echo connection safely
  Future<void> init() async {
    if (_echo != null && _isConnected) return;
    if (_isInitializing) return;

    _isInitializing = true;

    try {
      final String key = AppEnv.pusherAppKey;
      final String cluster = AppEnv.pusherAppCluster;

      if (key.isEmpty) {
        debugPrint("⚠️ [EchoService] PUSHER_APP_KEY is not configured in .env");
        _isInitializing = false;
        return;
      }

      final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

      await pusher.init(
        apiKey: key,
        cluster: cluster,
        useTLS: true,
        onConnectionStateChange: (currentState, previousState) {
          debugPrint("📡 [EchoService] Pusher state: $previousState -> $currentState");
          _isConnected = (currentState == 'CONNECTED');
        },
        onError: (message, code, exception) {
          debugPrint("❌ [EchoService] Pusher Error: $message (code: $code, ex: $exception)");
        },
      );

      await pusher.connect();

      _echo = Echo(
        broadcaster: EchoBroadcasterType.Pusher,
        client: pusher,
      );

      _isConnected = true;
      debugPrint("✅ [EchoService] Successfully connected to Real-time WebSocket!");
    } catch (e) {
      debugPrint("⚠️ [EchoService] WebSocket initialization error (Smart Polling handles fallback): $e");
      _isConnected = false;
      _echo = null;
    } finally {
      _isInitializing = false;
    }
  }

  void listenToAvailableTrips({
    required Function(Map<String, dynamic> data) onNewTrip,
    Function(Map<String, dynamic> data)? onTripNoLongerAvailable,
  }) {
    try {
      if (_echo == null) {
        init().then((_) {
          if (_echo != null) {
            _subscribeAvailableTrips(
              onNewTrip: onNewTrip,
              onTripNoLongerAvailable: onTripNoLongerAvailable,
            );
          }
        }).catchError((e) {
          debugPrint("⚠️ [EchoService] listenToAvailableTrips init error: $e");
        });
        return;
      }
      _subscribeAvailableTrips(
        onNewTrip: onNewTrip,
        onTripNoLongerAvailable: onTripNoLongerAvailable,
      );
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToAvailableTrips error: $e");
    }
  }

  void _subscribeAvailableTrips({
    required Function(Map<String, dynamic> data) onNewTrip,
    Function(Map<String, dynamic> data)? onTripNoLongerAvailable,
  }) {
    final echo = _echo;
    if (echo == null) return;
    try {
      echo.channel('trips.available')
        .listen('NewTripRequested', (dynamic event) {
          debugPrint("🔔 [EchoService] NewTripRequested event received: $event");
          if (event != null) {
            final Map<String, dynamic> parsed = _parseEventData(event);
            onNewTrip(parsed);
          }
        })
        .listen('TripStatusUpdated', (dynamic event) {
          debugPrint("🔄 [EchoService] TripStatusUpdated on trips.available: $event");
          if (event != null) {
            final Map<String, dynamic> parsed = _parseEventData(event);
            if (onTripNoLongerAvailable != null) {
              onTripNoLongerAvailable(parsed);
            }
          }
        });
      debugPrint("📡 [EchoService] Subscribed to channel: trips.available");
    } catch (e) {
      debugPrint("❌ [EchoService] Failed to listen to trips.available: $e");
    }
  }

  void stopListeningToAvailableTrips() {
    final echo = _echo;
    if (echo == null) return;
    try {
      echo.leave('trips.available');
      debugPrint("🔌 [EchoService] Left channel: trips.available");
    } catch (e) {
      debugPrint("❌ [EchoService] Error leaving trips.available: $e");
    }
  }

  /// 2. Listen for active trip status changes (For Passengers & Captains)
  void listenToTripStatus(String tripId, Function(Map<String, dynamic> data) onStatusUpdated) {
    try {
      if (_echo == null) {
        init().then((_) {
          if (_echo != null) {
            _subscribeTripStatus(tripId, onStatusUpdated);
          }
        }).catchError((e) {
          debugPrint("⚠️ [EchoService] listenToTripStatus init error: $e");
        });
        return;
      }
      _subscribeTripStatus(tripId, onStatusUpdated);
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToTripStatus error: $e");
    }
  }

  void _subscribeTripStatus(String tripId, Function(Map<String, dynamic> data) onStatusUpdated) {
    final echo = _echo;
    if (echo == null) return;
    try {
      final channelName = 'trip.$tripId';
      echo.channel(channelName).listen('TripStatusUpdated', (dynamic event) {
        debugPrint("🔔 [EchoService] TripStatusUpdated event received on $channelName: $event");
        if (event != null) {
          final Map<String, dynamic> parsed = _parseEventData(event);
          onStatusUpdated(parsed);
        }
      });
      debugPrint("📡 [EchoService] Subscribed to channel: $channelName");
    } catch (e) {
      debugPrint("❌ [EchoService] Failed to listen to trip.$tripId: $e");
    }
  }

  void stopListeningToTripStatus(String tripId) {
    final echo = _echo;
    if (echo == null) return;
    try {
      echo.leave('trip.$tripId');
      debugPrint("🔌 [EchoService] Left channel: trip.$tripId");
    } catch (e) {
      debugPrint("❌ [EchoService] Error leaving trip.$tripId: $e");
    }
  }

  /// 3. Listen for live captain GPS location (For Passenger Map)
  void listenToCaptainLocation(String captainId, Function(double lat, double lng, double? heading) onLocationUpdated) {
    try {
      if (_echo == null) {
        init().then((_) {
          if (_echo != null) {
            _subscribeCaptainLocation(captainId, onLocationUpdated);
          }
        }).catchError((e) {
          debugPrint("⚠️ [EchoService] listenToCaptainLocation init error: $e");
        });
        return;
      }
      _subscribeCaptainLocation(captainId, onLocationUpdated);
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToCaptainLocation error: $e");
    }
  }

  void _subscribeCaptainLocation(String captainId, Function(double lat, double lng, double? heading) onLocationUpdated) {
    final echo = _echo;
    if (echo == null) return;
    try {
      final channelName = 'captain-location.$captainId';
      echo.channel(channelName).listen('CaptainLocationUpdated', (dynamic event) {
        if (event != null) {
          final Map<String, dynamic> parsed = _parseEventData(event);
          final lat = (parsed['latitude'] as num?)?.toDouble();
          final lng = (parsed['longitude'] as num?)?.toDouble();
          final heading = (parsed['heading'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            onLocationUpdated(lat, lng, heading);
          }
        }
      });
      debugPrint("📡 [EchoService] Subscribed to channel: $channelName");
    } catch (e) {
      debugPrint("❌ [EchoService] Failed to listen to captain-location.$captainId: $e");
    }
  }

  void stopListeningToCaptainLocation(String captainId) {
    final echo = _echo;
    if (echo == null) return;
    try {
      echo.leave('captain-location.$captainId');
      debugPrint("🔌 [EchoService] Left channel: captain-location.$captainId");
    } catch (e) {
      debugPrint("❌ [EchoService] Error leaving captain-location.$captainId: $e");
    }
  }

  /// Helper to safely decode event payload
  Map<String, dynamic> _parseEventData(dynamic event) {
    if (event is Map<String, dynamic>) {
      return event;
    } else if (event is String) {
      try {
        final decoded = jsonDecode(event);
        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      } catch (_) {}
    }
    return {'data': event};
  }

  /// Disconnect and cleanup
  void disconnect() {
    final echo = _echo;
    if (echo != null) {
      try {
        echo.disconnect();
      } catch (_) {}
      _echo = null;
      _isConnected = false;
      debugPrint("🔌 [EchoService] Disconnected from WebSocket.");
    }
  }
}
