import 'package:equatable/equatable.dart';

class RideEntity extends Equatable {
  final String id;
  final String status;
  final double price;
  final String pickupLocation;
  final String dropoffLocation;
  final String? captainName;
  final double? rating;
  final String? vehicleModel;
  final String? vehiclePlate;

  const RideEntity({
    required this.id,
    required this.status,
    required this.price,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.captainName,
    this.rating,
    this.vehicleModel,
    this.vehiclePlate,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        price,
        pickupLocation,
        dropoffLocation,
        captainName,
        rating,
        vehicleModel,
        vehiclePlate,
      ];
}
