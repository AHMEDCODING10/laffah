import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter/foundation.dart';
import '../config/app_env.dart';
import '../storage/secure_storage_service.dart';

/// Centralized Real-time WebSocket Service for Laffah.
/// Manages subscriptions safely for:
/// 1. Available Trips for Online Captains (`trips.available`)
/// 2. Active Trip Status Updates (`trip.{id}`)
/// 3. Live Captain Location Tracking (`captain-location.{captainId}`)
class EchoService {
  static final EchoService _instance = EchoService._internal();
  factory EchoService() => _instance;
  EchoService._internal();

  PusherChannelsFlutter? _pusher;
  bool _isInitializing = false;
  bool _isConnected = false;

  final Map<String, List<Function(Map<String, dynamic>)>> _tripAvailableListeners = {};
  final Map<String, List<Function(Map<String, dynamic>)>> _tripStatusListeners = {};
  final Map<String, List<Function(double, double, double?)>> _captainLocationListeners = {};
  final List<Function(Map<String, dynamic>)> _forcedOfflineListeners = [];
  
  String _currentCaptainId = '';

  bool get isConnected => _isConnected;

  /// Initialize Pusher connection safely
  Future<void> init() async {
    if (_pusher != null && _isConnected) return;
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
      _pusher = pusher;

      await pusher.init(
        apiKey: key,
        cluster: cluster,
        useTLS: true,
        // [REALTIME FIX ISSUE-1.5]: Authorizer callback for private channels authorization
        onAuthorizer: (String channelName, String socketId, dynamic options) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final storage = SecureStorageService(const FlutterSecureStorage(), prefs);
            final token = await storage.getToken();

            final authUrl = "${AppEnv.apiBaseUrl}/broadcasting/auth";
            final dio = Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

            final response = await dio.post(
              authUrl,
              data: {
                'socket_id': socketId,
                'channel_name': channelName,
              },
              options: Options(
                headers: {
                  'Authorization': 'Bearer $token',
                  'Accept': 'application/json',
                },
                contentType: Headers.formUrlEncodedContentType,
              ),
            );
            return response.data;
          } catch (e) {
            debugPrint("❌ [EchoService] Channel authorizer error on $channelName: $e");
            return null;
          }
        },
        onConnectionStateChange: (currentState, previousState) {
          debugPrint("📡 [EchoService] Pusher state: $previousState -> $currentState");
          _isConnected = (currentState == 'CONNECTED');
        },
        onError: (message, code, exception) {
          debugPrint("❌ [EchoService] Pusher Error: $message (code: $code, ex: $exception)");
        },
        onEvent: (event) {
          _handleIncomingEvent(event);
        },
      );

      await pusher.connect();
      _isConnected = true;
      debugPrint("✅ [EchoService] Successfully connected to Real-time WebSocket!");
    } catch (e) {
      debugPrint("⚠️ [EchoService] WebSocket initialization (Smart Polling handles fallback): $e");
      _isConnected = false;
    } finally {
      _isInitializing = false;
    }
  }

  void _handleIncomingEvent(PusherEvent event) {
    final eventName = event.eventName;
    // Ignore internal Pusher protocol/handshake events
    if (eventName.startsWith('pusher:') || eventName.startsWith('pusher_internal:')) {
      return;
    }

    final channelName = event.channelName;
    final data = _parseEventData(event.data);
    if (data.isEmpty) return;

    if (channelName.startsWith('private-captain-location.')) {
      final captainId = channelName.replaceFirst('private-captain-location.', '');
      final listeners = _captainLocationListeners[captainId] ?? [];
      final lat = (data['latitude'] as num?)?.toDouble() ?? (data['lat'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble() ?? (data['lng'] as num?)?.toDouble();
      final heading = (data['heading'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        for (final callback in List.from(listeners)) {
          try {
            callback(lat, lng, heading);
          } catch (_) {}
        }
      }
    } else if (channelName == 'private-trips.available' || channelName.startsWith('private-captain.')) {
      if (eventName == 'CaptainForcedOffline' || data['event'] == 'CaptainForcedOffline' || data['reason'] == 'inactivity_timeout') {
        for (final callback in List.from(_forcedOfflineListeners)) {
          try {
            callback(data);
          } catch (_) {}
        }
        return;
      }
      // Must contain a valid trip ID or payload
      if (data['id'] == null && data['trip_id'] == null && data['tripId'] == null) {
        return;
      }
      final listeners = _tripAvailableListeners[channelName] ?? _tripAvailableListeners['private-trips.available'] ?? [];
      for (final callback in List.from(listeners)) {
        try {
          callback(data);
        } catch (_) {}
      }
    } else if (channelName.startsWith('private-trip.')) {
      final tripId = channelName.replaceFirst('private-trip.', '');
      final listeners = _tripStatusListeners[tripId] ?? [];
      for (final callback in List.from(listeners)) {
        try {
          callback(data);
        } catch (_) {}
      }
    }
  }

  Future<void> listenToAvailableTrips({
    required Function(Map<String, dynamic> data) onNewTrip,
    Function(Map<String, dynamic> data)? onTripNoLongerAvailable,
    String? captainId,
  }) async {
    try {
      if (captainId != null) {
          _currentCaptainId = captainId;
      }
      if (_pusher == null || !_isConnected) {
        await init();
      }
      final pusher = _pusher;
      if (pusher == null) return;

      _tripAvailableListeners.putIfAbsent('private-trips.available', () => []);
      _tripAvailableListeners['private-trips.available']!.add((data) {
        final eventType = data['event_type'] ?? data['type'];
        if (eventType == 'trip_cancelled' || eventType == 'trip_accepted' || eventType == 'trip_no_longer_available') {
          onTripNoLongerAvailable?.call(data);
        } else {
          onNewTrip(data);
        }
      });

      await pusher.subscribe(channelName: 'private-trips.available');
      debugPrint("📡 [EchoService] Subscribed to channel: private-trips.available");

      // Also subscribe to the targeted Smart Queue private channel
      final captainProfileId = _currentCaptainId; 
      if (captainProfileId.isNotEmpty) {
          await pusher.subscribe(channelName: 'private-captain.$captainProfileId');
          debugPrint("📡 [EchoService] Subscribed to targeted channel: private-captain.$captainProfileId");
          _tripAvailableListeners.putIfAbsent('private-captain.$captainProfileId', () => []);
          _tripAvailableListeners['private-captain.$captainProfileId']!.add((data) {
            final eventType = data['event_type'] ?? data['type'];
            if (eventType == 'trip_cancelled' || eventType == 'trip_accepted' || eventType == 'trip_no_longer_available') {
              onTripNoLongerAvailable?.call(data);
            } else {
              onNewTrip(data);
            }
          });
      }
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToAvailableTrips (handled by Smart Polling): $e");
    }
  }

  Future<void> stopListeningToAvailableTrips() async {
    final pusher = _pusher;
    if (pusher == null) return;
    try {
      _tripAvailableListeners.remove('private-trips.available');
      await pusher.unsubscribe(channelName: 'private-trips.available');
      
      if (_currentCaptainId.isNotEmpty) {
          _tripAvailableListeners.remove('private-captain.$_currentCaptainId');
          await pusher.unsubscribe(channelName: 'private-captain.$_currentCaptainId');
      }
      debugPrint("🔌 [EchoService] Left trip channels");
    } catch (e) {
      debugPrint("⚠️ [EchoService] Error leaving trips.available: $e");
    }
  }

  Future<void> listenToTripStatus(String tripId, Function(Map<String, dynamic> data) onStatusUpdated) async {
    try {
      if (_pusher == null || !_isConnected) {
        await init();
      }
      final pusher = _pusher;
      if (pusher == null) return;

      _tripStatusListeners.putIfAbsent(tripId, () => []);
      _tripStatusListeners[tripId]!.add(onStatusUpdated);

      await pusher.subscribe(channelName: 'private-trip.$tripId');
      debugPrint("📡 [EchoService] Subscribed to channel: private-trip.$tripId");
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToTripStatus: $e");
    }
  }

  Future<void> stopListeningToTripStatus(String tripId) async {
    final pusher = _pusher;
    if (pusher == null) return;
    try {
      _tripStatusListeners.remove(tripId);
      await pusher.unsubscribe(channelName: 'private-trip.$tripId');
      debugPrint("🔌 [EchoService] Left channel: private-trip.$tripId");
    } catch (e) {
      debugPrint("⚠️ [EchoService] Error leaving private-trip.$tripId: $e");
    }
  }

  Future<void> listenToCaptainLocation(String captainId, Function(double lat, double lng, double? heading) onLocationUpdated) async {
    try {
      if (_pusher == null || !_isConnected) {
        await init();
      }
      final pusher = _pusher;
      if (pusher == null) return;

      _captainLocationListeners.putIfAbsent(captainId, () => []);
      _captainLocationListeners[captainId]!.add(onLocationUpdated);

      await pusher.subscribe(channelName: 'private-captain-location.$captainId');
      debugPrint("📡 [EchoService] Subscribed to channel: private-captain-location.$captainId");
    } catch (e) {
      debugPrint("⚠️ [EchoService] listenToCaptainLocation: $e");
    }
  }

  Future<void> stopListeningToCaptainLocation(String captainId) async {
    final pusher = _pusher;
    if (pusher == null) return;
    try {
      _captainLocationListeners.remove(captainId);
      await pusher.unsubscribe(channelName: 'private-captain-location.$captainId');
      debugPrint("🔌 [EchoService] Left channel: private-captain-location.$captainId");
    } catch (e) {
      debugPrint("⚠️ [EchoService] Error leaving private-captain-location.$captainId: $e");
    }
  }

  void listenToForcedOffline(Function(Map<String, dynamic> data) onForcedOffline) {
    if (!_forcedOfflineListeners.contains(onForcedOffline)) {
      _forcedOfflineListeners.add(onForcedOffline);
    }
  }

  void stopListeningToForcedOffline(Function(Map<String, dynamic> data) onForcedOffline) {
    _forcedOfflineListeners.remove(onForcedOffline);
  }

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

  Future<void> disconnect() async {
    final pusher = _pusher;
    if (pusher != null) {
      try {
        await pusher.disconnect();
      } catch (_) {}
      _pusher = null;
      _isConnected = false;
      debugPrint("🔌 [EchoService] Disconnected from WebSocket.");
    }
  }
}
