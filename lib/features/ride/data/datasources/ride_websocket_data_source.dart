import 'dart:async';
import '../../../../core/network/websocket_client.dart';
import '../../domain/entities/ride_entity.dart';
import '../models/ride_model.dart';

class CaptainLocationUpdate {
  final double lat;
  final double lng;
  final double heading;
  final DateTime timestamp;

  const CaptainLocationUpdate({
    required this.lat,
    required this.lng,
    required this.heading,
    required this.timestamp,
  });
}

abstract class RideWebSocketDataSource {
  Stream<RideEntity> subscribeToRideUpdates(String rideId);
  Stream<CaptainLocationUpdate> subscribeToCaptainLocation(String rideId);
  Future<void> unsubscribe();
}

class RideWebSocketDataSourceImpl implements RideWebSocketDataSource {
  final LaffahWebSocketClient wsClient;

  RideWebSocketDataSourceImpl(this.wsClient);

  @override
  Stream<RideEntity> subscribeToRideUpdates(String rideId) {
    wsClient.connect('ride.$rideId');

    return wsClient.events
        .where((event) => event['event'] == 'ride.status.updated')
        .map((event) {
      final data = event['data'] as Map<String, dynamic>;
      return RideModel.fromJson(data);
    });
  }

  @override
  Stream<CaptainLocationUpdate> subscribeToCaptainLocation(String rideId) {
    return wsClient.events
        .where((event) => event['event'] == 'captain.location.updated')
        .map((event) {
      final data = event['data'] as Map<String, dynamic>;
      return CaptainLocationUpdate(
        lat: (data['latitude'] as num).toDouble(),
        lng: (data['longitude'] as num).toDouble(),
        heading: (data['heading'] as num?)?.toDouble() ?? 0,
        timestamp: DateTime.tryParse(data['timestamp'] ?? '') ?? DateTime.now(),
      );
    });
  }

  @override
  Future<void> unsubscribe() async {
    await wsClient.disconnect();
  }
}
