import 'package:equatable/equatable.dart';

export 'saved_place_entity.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String role; // passenger, captain

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    required this.role,
  });

  @override
  List<Object?> get props => [id, name, phone, email, avatarUrl, role];
}
