import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

/// Event triggered when the user submits phone + password to log in.
class LoginRequested extends AuthEvent {
  final String phone;
  final String password;

  const LoginRequested({required this.phone, required this.password});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequested &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          password == other.password;

  @override
  int get hashCode => phone.hashCode ^ password.hashCode;
}

/// Event triggered when a passenger submits their full registration form.
class RegisterPassengerRequested extends AuthEvent {
  final String name;
  final String phone;
  final String password;

  const RegisterPassengerRequested({
    required this.name,
    required this.phone,
    required this.password,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterPassengerRequested &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone &&
          password == other.password;

  @override
  int get hashCode => name.hashCode ^ phone.hashCode ^ password.hashCode;
}

/// Event triggered when a captain submits their full registration form.
class RegisterCaptainRequested extends AuthEvent {
  final String name;
  final String phone;
  final String password;
  final String vehicleType;
  final String vehicleModel;
  final int vehicleYear;
  final String vehiclePlate;

  const RegisterCaptainRequested({
    required this.name,
    required this.phone,
    required this.password,
    required this.vehicleType,
    required this.vehicleModel,
    required this.vehicleYear,
    required this.vehiclePlate,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterCaptainRequested &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          phone == other.phone &&
          password == other.password &&
          vehicleType == other.vehicleType &&
          vehicleModel == other.vehicleModel &&
          vehicleYear == other.vehicleYear &&
          vehiclePlate == other.vehiclePlate;

  @override
  int get hashCode =>
      name.hashCode ^
      phone.hashCode ^
      password.hashCode ^
      vehicleType.hashCode ^
      vehicleModel.hashCode ^
      vehicleYear.hashCode ^
      vehiclePlate.hashCode;
}

/// Event triggered when user taps Logout button.
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Event triggered when user taps Delete Account button.
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}

class ForgotPasswordRequested extends AuthEvent {
  final String phone;
  const ForgotPasswordRequested({required this.phone});
}

class VerifyResetCodeRequested extends AuthEvent {
  final String phone;
  final String code;
  const VerifyResetCodeRequested({required this.phone, required this.code});
}

class ResetPasswordRequested extends AuthEvent {
  final String phone;
  final String code;
  final String newPassword;
  const ResetPasswordRequested(
      {required this.phone, required this.code, required this.newPassword});
}
