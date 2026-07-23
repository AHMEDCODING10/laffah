import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String phone;
  final String name;
  final String role; // passenger, captain
  final String? token;

  const UserEntity({
    required this.id,
    required this.phone,
    required this.name,
    required this.role,
    this.token,
  });

  @override
  List<Object?> get props => [id, phone, name, role, token];
}
