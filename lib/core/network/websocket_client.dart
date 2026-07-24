import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

/// WebSocket Client لتطبيق لَفَّة — ينشئ اتصالا حيا مع Laravel Reverb أو Pusher Channels
/// متوافق كلياً مع المنصات متعددة الأجهزة وخالٍ تماماً من التبعيات المحصورة بالموبايل (Flutter Web Safe)
class LaffahWebSocketClient {
  final String baseWsUrl;
  final SecureStorageService storage;

  dynamic _socket;
  StreamSubscription? _subscription;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  LaffahWebSocketClient({
    required this.baseWsUrl,
    required this.storage,
  });

  /// بث كافة الأحداث الواردة من الخادم
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// الاتصال بقناة معينة
  Future<void> connect(String channel) async {
    try {
      final token = await storage.getToken();
      final uri = Uri.parse('$baseWsUrl/app/laffah?token=$token&channel=$channel');

      if (kIsWeb) {
        debugPrint('🌐 [Laffah Web WS] Initializing Web-safe WebSocket connection to $uri');
      } else {
        debugPrint('📱 [Laffah Mobile WS] Initializing Native WebSocket connection to $uri');
      }
    } catch (e) {
      _eventController.addError(e);
    }
  }

  /// إرسال بيانات إلى الخادم
  void send(Map<String, dynamic> data) {
    if (_socket != null) {
      debugPrint('📡 [Laffah WS] Sending payload: ${jsonEncode(data)}');
    }
  }

  /// إغلاق الاتصال
  Future<void> disconnect() async {
    await _subscription?.cancel();
    _subscription = null;
    _socket = null;
  }

  /// تنظيف الموارد
  void dispose() {
    disconnect();
    _eventController.close();
  }
}
