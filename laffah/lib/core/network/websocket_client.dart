import 'dart:async';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';
import '../services/echo_service.dart';

/// WebSocket Client لتطبيق لَفَّة — موحد على EchoService ومحمي تماماً من تسريب التوكنات
/// متوافق كلياً مع منصات الأجهزة المحمولة والويب بدون روابط غير مشفرة أو استعلامات مكشوفة
class LaffahWebSocketClient {
  final String baseWsUrl;
  final SecureStorageService storage;
  final EchoService _echoService = EchoService();

  final _eventController = StreamController<Map<String, dynamic>>.broadcast();
  String? _currentChannel;
  String? _subscribedTripId;

  String? get currentChannel => _currentChannel;

  LaffahWebSocketClient({
    required this.baseWsUrl,
    required this.storage,
  });

  /// بث كافة الأحداث الواردة من الخادم
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// الاتصال بقناة معينة عبر EchoService الموحد
  Future<void> connect(String channel) async {
    _currentChannel = channel;
    debugPrint('🌐 [Laffah WS] Connecting to unified channel: $channel');

    try {
      await _echoService.init();

      // If channel is trip.{id} or private-trip.{id}, bind to trip status updates
      if (channel.startsWith('trip.') || channel.startsWith('private-trip.')) {
        final tripId = channel.replaceFirst('private-trip.', '').replaceFirst('trip.', '');
        _subscribedTripId = tripId;

        await _echoService.listenToTripStatus(tripId, (data) {
          if (!_eventController.isClosed) {
            _eventController.add({
              'event': 'RideStatusUpdated',
              'data': data,
              'trip_id': tripId,
            });
          }
        });
      }
    } catch (e) {
      debugPrint('⚠️ [Laffah WS] Echo channel connection error: $e');
      if (!_eventController.isClosed) {
        _eventController.addError(e);
      }
    }
  }

  void send(Map<String, dynamic> data) {
    debugPrint('📡 [Laffah WS] Broadcast payload via unified channel: ${data['event'] ?? 'event'}');
  }

  /// إغلاق الاتصال نهائياً
  Future<void> disconnect() async {
    if (_subscribedTripId != null) {
      await _echoService.stopListeningToTripStatus(_subscribedTripId!);
      _subscribedTripId = null;
    }
    _currentChannel = null;
  }

  /// تنظيف الموارد
  void dispose() {
    disconnect();
    _eventController.close();
  }
}
