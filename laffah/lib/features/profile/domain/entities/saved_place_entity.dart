import 'package:equatable/equatable.dart';

class SavedPlaceEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String type; // home, work, custom

  const SavedPlaceEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.type,
  });

  @override
  List<Object?> get props => [id, name, address, lat, lng, type];
}
