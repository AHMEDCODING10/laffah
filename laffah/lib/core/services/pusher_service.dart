import 'echo_service.dart';

/// PusherService adapter delegating to the unified [EchoService]
class PusherService {
  final EchoService _echoService = EchoService();

  bool get isConnected => _echoService.isConnected;

  /// Connect and listen to incoming trip requests and status dismissals
  void connect({
    required String captainId,
    required Function(Map<String, dynamic> data) onTripRequest,
    Function(Map<String, dynamic> data)? onTripNoLongerAvailable,
  }) {
    _echoService.init().then((_) {
      _echoService.listenToAvailableTrips(
        onNewTrip: onTripRequest,
        onTripNoLongerAvailable: onTripNoLongerAvailable,
      );
    });
  }

  /// Disconnect
  void disconnect() {
    _echoService.stopListeningToAvailableTrips();
  }
}
