import 'package:equatable/equatable.dart';

class CaptainStatusEntity extends Equatable {
  final String id;
  final bool isOnline;
  final double currentLat;
  final double currentLng;
  final String statusMessage;

  const CaptainStatusEntity({
    required this.id,
    required this.isOnline,
    required this.currentLat,
    required this.currentLng,
    required this.statusMessage,
  });

  @override
  List<Object?> get props =>
      [id, isOnline, currentLat, currentLng, statusMessage];

  /// Alias for use with PusherService channel subscription
  String? get captainId => id.isNotEmpty ? id : null;
}
