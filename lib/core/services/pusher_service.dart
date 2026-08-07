import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

/// خدمة Pusher WebSocket المجانية المباشرة لطلبات الرحلات الحية
class PusherService {
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  /// الاتصال بسيرفر Pusher عبر WebSocket المباشر
  void connect({
    required String captainId,
    required Function(Map<String, dynamic> data) onTripRequest,
  }) {
    final appKey = dotenv.env['PUSHER_APP_KEY'] ?? '68404469b114b177fd46';
    final cluster = dotenv.env['PUSHER_APP_CLUSTER'] ?? 'eu';

    if (appKey.isEmpty) return;

    // رابط Pusher WebSocket المباشر الرسمية
    final wsUrl = Uri.parse(
      'wss://ws-$cluster.pusher.com/app/$appKey?protocol=7&client=js&version=7.0.6&flash=false',
    );

    try {
      _channel = WebSocketChannel.connect(wsUrl);
      _isConnected = true;

      _subscription = _channel!.stream.listen(
        (message) {
          _handleMessage(message.toString(), captainId, onTripRequest);
        },
        onError: (error) {
          _isConnected = false;
        },
        onDone: () {
          _isConnected = false;
        },
      );
    } catch (_) {
      _isConnected = false;
    }
  }

  void _handleMessage(
    String messageStr,
    String captainId,
    Function(Map<String, dynamic> data) onTripRequest,
  ) {
    try {
      final jsonMap = json.decode(messageStr) as Map<String, dynamic>;
      final event = jsonMap['event'] as String?;

      // عند اكتمال مصافحة الاتصال بـ Pusher -> الاشتراك في قناة الكابتن
      if (event == 'pusher:connection_established') {
        _subscribeToChannel('captain-$captainId');
      } else if (event == 'trip.new_request' || event == 'trip_request') {
        final rawData = jsonMap['data'];
        final data = rawData is String
            ? json.decode(rawData) as Map<String, dynamic>
            : rawData as Map<String, dynamic>;

        onTripRequest(data);
      }
    } catch (_) {}
  }

  void _subscribeToChannel(String channelName) {
    if (_channel != null && _isConnected) {
      final subscribePayload = json.encode({
        'event': 'pusher:subscribe',
        'data': {'channel': channelName},
      });
      _channel!.sink.add(subscribePayload);
    }
  }

  /// قطع الاتصال
  void disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    _isConnected = false;
  }
}
