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
      id: json['id']?.toString() ?? '',
      isOnline: json['is_online'] == true ||
          json['is_online'] == 1 ||
          json['isOnline'] == true ||
          json['isOnline'] == 1,
      currentLat: (json['lat'] as num?)?.toDouble() ??
          (json['latitude'] as num?)?.toDouble() ??
          (json['currentLat'] as num?)?.toDouble() ??
          0.0,
      currentLng: (json['lng'] as num?)?.toDouble() ??
          (json['longitude'] as num?)?.toDouble() ??
          (json['currentLng'] as num?)?.toDouble() ??
          0.0,
      statusMessage: json['status_message'] as String? ??
          json['statusMessage'] as String? ??
          json['message'] as String? ??
          '',
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
