import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../storage/secure_storage_service.dart';

/// WebSocket Client لتطبيق لَفَّة — ينشئ اتصالا حيا مع Laravel Reverb أو Pusher Channels
/// متوافق كلياً مع المنصات متعددة الأجهزة وخالٍ تماماً من التبعيات المحصورة بالموبايل (Flutter Web Safe)
///
/// 🚨 CATASTROPHIC WARNING FOR CAPTAIN LOCATION TRACKING 🚨
/// --------------------------------------------------------
/// NEVER build an HTTP POST API (DioClient) to send the Captain's live location.
/// Pinging the server via HTTP every 3 seconds for 1000+ active captains will cause a self-DDoS
/// attack and instantly crash the Laravel server.
/// ALL live location updates MUST be broadcasted using `LaffahWebSocketClient.send(...)`.
class LaffahWebSocketClient {
  final String baseWsUrl;
  final SecureStorageService storage;

  WebSocketChannel? _socket;
  StreamSubscription? _subscription;
  final _eventController = StreamController<Map<String, dynamic>>.broadcast();

  int _reconnectAttempts = 0;
  bool _isConnecting = false;
  String? _currentChannel;

  LaffahWebSocketClient({
    required this.baseWsUrl,
    required this.storage,
  });

  /// بث كافة الأحداث الواردة من الخادم
  Stream<Map<String, dynamic>> get events => _eventController.stream;

  /// الاتصال بقناة معينة مع خوارزمية Exponential Backoff
  Future<void> connect(String channel) async {
    if (_isConnecting) return;
    _isConnecting = true;
    _currentChannel = channel;

    try {
      final token = await storage.getToken();

      // Using query parameters for token to ensure Web compatibility without conditional imports
      final uri =
          Uri.parse('$baseWsUrl/app/laffah?token=$token&channel=$channel');
      debugPrint('🌐 [Laffah WS] Connecting to $uri');

      _socket = WebSocketChannel.connect(uri);

      _reconnectAttempts = 0;
      _isConnecting = false;

      // Attach real socket listeners
      _subscription = _socket!.stream.listen(
        (data) {
          try {
            if (data is String) {
              final Map<String, dynamic> decoded = jsonDecode(data);
              
              // Handle Pusher Protocol: connection_established
              if (decoded['event'] == 'pusher:connection_established') {
                debugPrint('🌐 [Laffah WS] Connection established. Subscribing to channel: $_currentChannel');
                send({
                  "event": "pusher:subscribe",
                  "data": {
                    "channel": _currentChannel
                  }
                });
              }
              
              _eventController.add(decoded);
            }
          } catch (e) {
            debugPrint('⚠️ [Laffah WS] Message decode error: $e');
          }
        },
        onError: (e) {
          debugPrint('⚠️ [Laffah WS] Stream error: $e');
          _handleDisconnect();
        },
        onDone: () {
          debugPrint('⚠️ [Laffah WS] Connection closed');
          _handleDisconnect();
        },
      );
    } catch (e) {
      _isConnecting = false;
      _eventController.addError(e);
      _handleDisconnect();
    }
  }

  /// معالجة انقطاع الاتصال والمحاولة من جديد بتأخير يتضاعف
  void _handleDisconnect() {
    _socket = null;
    _isConnecting = false;

    if (_currentChannel == null) return; // تم قطع الاتصال يدوياً

    // مضاعفة الوقت (2, 4, 8, 16، وبحد أقصى 32 ثانية)
    final int nextBackoffSeconds =
        (1 << (_reconnectAttempts > 5 ? 5 : _reconnectAttempts));
    _reconnectAttempts++;

    debugPrint(
        '⚠️ [Laffah WS] Connection lost. Attempting reconnect in $nextBackoffSeconds seconds... (Attempt $_reconnectAttempts)');

    Future.delayed(Duration(seconds: nextBackoffSeconds), () {
      if (_socket == null && _currentChannel != null) {
        connect(_currentChannel!);
      }
    });
  }

  void send(Map<String, dynamic> data) {
    if (_socket != null) {
      final payload = jsonEncode(data);
      debugPrint('📡 [Laffah WS] Sending payload: $payload');
      _socket!.sink.add(payload);
    }
  }

  /// إغلاق الاتصال نهائياً
  Future<void> disconnect() async {
    _currentChannel = null;
    _isConnecting = false;
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
