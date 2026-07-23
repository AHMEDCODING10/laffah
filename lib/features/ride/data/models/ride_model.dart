import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.status,
    required super.price,
    required super.pickupLocation,
    required super.dropoffLocation,
    super.captainName,
    super.rating,
    super.vehicleModel,
    super.vehiclePlate,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'].toString(),
      status: json['status'] ?? 'pending',
      price: (json['price'] ?? 0).toDouble(),
      pickupLocation: json['pickup_location'] ?? '',
      dropoffLocation: json['dropoff_location'] ?? '',
      captainName: json['captain_name'],
      rating: json['rating'] != null ? (json['rating']).toDouble() : null,
      vehicleModel: json['vehicle_model'],
      vehiclePlate: json['vehicle_plate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'price': price,
      'pickup_location': pickupLocation,
      'dropoff_location': dropoffLocation,
      'captain_name': captainName,
      'rating': rating,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
    };
  }
}
