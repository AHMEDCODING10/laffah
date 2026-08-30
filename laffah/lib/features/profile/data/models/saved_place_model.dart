import '../../domain/entities/saved_place_entity.dart';

class SavedPlaceModel extends SavedPlaceEntity {
  const SavedPlaceModel({
    required super.id,
    required super.name,
    required super.address,
    required super.lat,
    required super.lng,
    required super.type,
  });

  factory SavedPlaceModel.fromJson(Map<String, dynamic> json) {
    return SavedPlaceModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) ?? 0.0 : 0.0,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) ?? 0.0 : 0.0,
      type: json['type'] ?? 'custom',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'type': type,
    };
  }
}
