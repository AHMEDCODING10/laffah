import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.phone,
    required super.name,
    required super.role,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // Backend response: data = { "user": {...}, "token": "..." }
    // OR flat response: data = { "id": ..., "token": "..." }
    final Map<String, dynamic> userMap = json['user'] != null
        ? Map<String, dynamic>.from(json['user'] as Map)
        : json;
    final String? token = json['token'] as String?;

    return UserModel(
      id: userMap['id'].toString(),
      phone: userMap['phone'] ?? '',
      name: userMap['name'] ?? '',
      role: (userMap['roles'] as List?)?.isNotEmpty == true
          ? ((userMap['roles'] as List).any((r) => r is Map && r['name'] == 'captain') ? 'captain' : (userMap['roles'][0]['name'] ?? 'passenger'))
          : (userMap['role'] ?? 'passenger'),
      token: token,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phone,
      'name': name,
      'role': role,
      'token': token,
    };
  }
}
