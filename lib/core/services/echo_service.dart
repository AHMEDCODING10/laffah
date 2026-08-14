import 'package:laravel_echo/laravel_echo.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:flutter/foundation.dart';

class EchoService {
  static final EchoService _instance = EchoService._internal();
  factory EchoService() => _instance;
  EchoService._internal();

  Echo? _echo;

  Echo? get echo => _echo;

  Future<void> init() async {
    try {
      final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();

      // We configure Pusher client to connect to our local Reverb server.
      // Replace with your actual local IP (e.g. 192.168.x.x) or domain instead of localhost if testing on real device.
      const String key = String.fromEnvironment('VITE_PUSHER_APP_KEY',
          defaultValue: '68404469b114b177fd46'); // Your Pusher/Reverb Key

      await pusher.init(
        apiKey: key,
        cluster: 'eu',
        useTLS: true,
      );

      await pusher.connect();

      _echo = Echo(
        broadcaster: EchoBroadcasterType.Pusher,
        client: pusher,
      );

      debugPrint("EchoService initialized successfully connected to Reverb!");
    } catch (e) {
      debugPrint("EchoService initialization error: $e");
    }
  }

  void listenToCaptainLocation(
      String captainId, Function(Map<String, dynamic>) onLocationUpdate) {
    if (_echo == null) return;

    // We used a public Channel in our Laravel Event
    _echo!
        .channel('captain-location.$captainId')
        .listen('CaptainLocationUpdated', (e) {
      if (e != null) {
        onLocationUpdate(e as Map<String, dynamic>);
      }
    });
  }

  void stopListeningToCaptainLocation(String captainId) {
    if (_echo == null) return;
    _echo!.leave('captain-location.$captainId');
  }
}
