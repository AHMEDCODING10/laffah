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
    final captain = json['captain_profile'] ?? json['captainProfile'];
    final rolesList = json['roles'] as List?;
    String resolvedRole = json['role']?.toString() ??
        (rolesList != null && rolesList.isNotEmpty
            ? rolesList[0]['name']?.toString() ?? 'passenger'
            : (captain != null ? 'captain' : 'passenger'));

    double? parsedRating;
    if (captain != null && captain['rating'] != null) {
      parsedRating = double.tryParse(captain['rating'].toString());
    } else if (json['rating'] != null) {
      parsedRating = double.tryParse(json['rating'].toString());
    }

    return ProfileModel(
      id: (json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      email: json['email']?.toString(),
      avatarUrl: json['avatar_url']?.toString() ?? json['avatar']?.toString(),
      role: resolvedRole,
      vehicleType: (captain?['vehicle_type'] ?? captain?['vehicleType'])?.toString(),
      vehicleModel: (captain?['vehicle_model'] ?? captain?['vehicleModel'])?.toString(),
      plateNumber: (captain?['plate_number'] ?? captain?['plateNumber'])?.toString(),
      rating: parsedRating,
      isVerified: captain?['is_verified'] == true ||
          captain?['is_verified'] == 1 ||
          captain?['isVerified'] == true ||
          captain?['isVerified'] == 1,
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
