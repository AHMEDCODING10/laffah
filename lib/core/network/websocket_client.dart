import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '../storage/secure_storage_service.dart';

/// WebSocket Client لتطبيق لَفَّة — ينشئ اتصالا حيا مع Laravel Reverb أو Pusher Channels
/// يُستخدم لتتبع موقع الكابتن لحظياً وتحديث حالة الرحلة
class LaffahWebSocketClient {
  final String baseWsUrl;
  final SecureStorageService storage;

  WebSocket? _socket;
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

      _socket = await WebSocket.connect(uri.toString());

      _subscription = _socket!.listen(
        (data) {
          try {
            final decoded = jsonDecode(data.toString());
            if (decoded is Map<String, dynamic>) {
              _eventController.add(decoded);
            }
          } catch (_) {}
        },
        onError: (error) {
          _eventController.addError(error);
        },
        onDone: () {
          // إعادة الاتصال التلقائي
          Future.delayed(const Duration(seconds: 3), () {
            if (_socket == null) connect(channel);
          });
        },
      );
    } catch (e) {
      _eventController.addError(e);
    }
  }

  /// إرسال بيانات إلى الخادم
  void send(Map<String, dynamic> data) {
    if (_socket != null && _socket!.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(data));
    }
  }

  /// إغلاق الاتصال
  Future<void> disconnect() async {
    await _subscription?.cancel();
    await _socket?.close();
    _subscription = null;
    _socket = null;
  }

  /// تنظيف الموارد
  void dispose() {
    disconnect();
    _eventController.close();
  }
}
