import '../../domain/entities/captain_status_entity.dart';

class CaptainStatusModel extends CaptainStatusEntity {
  const CaptainStatusModel({
    required super.id,
    required super.isOnline,
    required super.currentLat,
    required super.currentLng,
    required super.statusMessage,
  });

  factory CaptainStatusModel.fromJson(Map<String, dynamic> json) {
    return CaptainStatusModel(
      id: json['id'].toString(),
      isOnline: json['is_online'] == true || json['is_online'] == 1,
      currentLat: (json['lat'] ?? 0).toDouble(),
      currentLng: (json['lng'] ?? 0).toDouble(),
      statusMessage: json['status_message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_online': isOnline,
      'lat': currentLat,
      'lng': currentLng,
      'status_message': statusMessage,
    };
  }
}
