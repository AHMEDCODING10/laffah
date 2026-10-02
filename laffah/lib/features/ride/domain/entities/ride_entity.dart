import 'package:equatable/equatable.dart';

class RideEntity extends Equatable {
  final String id;
  final String status;
  final double price;
  final String pickupLocation;
  final String dropoffLocation;
  final double? pickupLatitude;
  final double? pickupLongitude;
  final double? dropoffLatitude;
  final double? dropoffLongitude;
  final double? distanceKm;
  final String? captainName;
  final String? captainPhone;
  final double? rating;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? distanceString;
  final String? durationString;
  final String? paymentMethod;

  const RideEntity({
    required this.id,
    required this.status,
    required this.price,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLatitude,
    this.pickupLongitude,
    this.dropoffLatitude,
    this.dropoffLongitude,
    this.distanceKm,
    this.captainName,
    this.captainPhone,
    this.rating,
    this.vehicleModel,
    this.vehiclePlate,
    this.distanceString,
    this.durationString,
    this.paymentMethod,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        price,
        pickupLocation,
        dropoffLocation,
        pickupLatitude,
        pickupLongitude,
        dropoffLatitude,
        dropoffLongitude,
        distanceKm,
        captainName,
        captainPhone,
        rating,
        vehicleModel,
        vehiclePlate,
        distanceString,
        durationString,
        paymentMethod,
      ];
}

