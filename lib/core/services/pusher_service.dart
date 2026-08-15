import 'echo_service.dart';

/// PusherService adapter delegating to the unified [EchoService]
class PusherService {
  final EchoService _echoService = EchoService();

  bool get isConnected => _echoService.isConnected;

  /// Connect and listen to incoming trip requests
  void connect({
    required String captainId,
    required Function(Map<String, dynamic> data) onTripRequest,
  }) {
    _echoService.init().then((_) {
      _echoService.listenToAvailableTrips(onTripRequest);
    });
  }

  /// Disconnect
  void disconnect() {
    _echoService.stopListeningToAvailableTrips();
  }
}
