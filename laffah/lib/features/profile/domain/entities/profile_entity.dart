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

  ProfileEntity copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? role,
    String? vehicleType,
    String? vehicleModel,
    String? plateNumber,
    double? rating,
    bool? isVerified,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      plateNumber: plateNumber ?? this.plateNumber,
      rating: rating ?? this.rating,
      isVerified: isVerified ?? this.isVerified,
    );
  }

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
