import 'package:equatable/equatable.dart';

export 'saved_place_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role; // passenger, captain

  // Captain specific properties
  final String? vehicleType;
  final String? vehicleModel;
  final String? plateNumber;
  final double? rating;
  final bool isVerified;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
    this.vehicleType,
    this.vehicleModel,
    this.plateNumber,
    this.rating,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        avatarUrl,
        role,
        vehicleType,
        vehicleModel,
        plateNumber,
        rating,
        isVerified
      ];
}
