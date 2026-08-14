import '../../domain/entities/profile_entity.dart';

export 'saved_place_model.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    required super.name,
    required super.phone,
    super.email,
    super.avatarUrl,
    required super.role,
    super.vehicleType,
    super.vehicleModel,
    super.plateNumber,
    super.rating,
    super.isVerified,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'],
      avatarUrl: json['avatar_url'],
      role: json['role'] ?? 'passenger',
      vehicleType: json['captain_profile']?['vehicle_type'],
      vehicleModel: json['captain_profile']?['vehicle_model'],
      plateNumber: json['captain_profile']?['plate_number'],
      rating: json['captain_profile']?['rating'] != null
          ? double.tryParse(json['captain_profile']['rating'].toString())
          : null,
      isVerified: json['captain_profile']?['is_verified'] == true ||
          json['captain_profile']?['is_verified'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'role': role,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'plate_number': plateNumber,
      'rating': rating,
      'is_verified': isVerified,
    };
  }
}
