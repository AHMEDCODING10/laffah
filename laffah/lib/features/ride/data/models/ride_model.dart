import '../../domain/entities/ride_entity.dart';

class RideModel extends RideEntity {
  const RideModel({
    required super.id,
    required super.status,
    required super.price,
    required super.pickupLocation,
    required super.dropoffLocation,
    super.pickupLatitude,
    super.pickupLongitude,
    super.dropoffLatitude,
    super.dropoffLongitude,
    super.distanceKm,
    super.captainName,
    super.captainPhone,
    super.rating,
    super.vehicleModel,
    super.vehiclePlate,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    final double parsedPrice = (json['price'] != null)
        ? (json['price'] as num).toDouble()
        : (json['estimated_price'] != null)
            ? (json['estimated_price'] as num).toDouble()
            : 0.0;

    final String pickup = (json['pickup_address'] ?? json['pickup_location'] ?? json['pickup'] ?? '').toString();
    final String dropoff = (json['dropoff_address'] ?? json['dropoff_location'] ?? json['dropoff'] ?? '').toString();

    final String? captainName = json['captain_name'] ??
        (json['captain'] is Map && json['captain']['user'] is Map
            ? json['captain']['user']['name']
            : null);

    final String? captainPhone = json['captain_phone'] ??
        (json['captain'] is Map && json['captain']['user'] is Map
            ? json['captain']['user']['phone']
            : null);

    final String? vehicleModel = json['vehicle_model'] ??
        (json['captain'] is Map ? json['captain']['vehicle_model'] : null);

    final String? vehiclePlate = json['vehicle_plate'] ??
        (json['captain'] is Map ? json['captain']['plate_number'] : null);

    return RideModel(
      id: json['id'].toString(),
      status: (json['status'] ?? 'pending').toString(),
      price: parsedPrice,
      pickupLocation: pickup,
      dropoffLocation: dropoff,
      pickupLatitude: (json['pickup_latitude'] as num?)?.toDouble(),
      pickupLongitude: (json['pickup_longitude'] as num?)?.toDouble(),
      dropoffLatitude: (json['dropoff_latitude'] as num?)?.toDouble(),
      dropoffLongitude: (json['dropoff_longitude'] as num?)?.toDouble(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      captainName: captainName,
      captainPhone: captainPhone,
      rating: (json['rating'] as num?)?.toDouble(),
      vehicleModel: vehicleModel,
      vehiclePlate: vehiclePlate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'price': price,
      'estimated_price': price,
      'pickup_address': pickupLocation,
      'dropoff_address': dropoffLocation,
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      'distance_km': distanceKm,
      'captain_name': captainName,
      'captain_phone': captainPhone,
      'rating': rating,
      'vehicle_model': vehicleModel,
      'vehicle_plate': vehiclePlate,
    };
  }
}

