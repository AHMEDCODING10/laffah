import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}

class UpdateUserProfile extends AuthEvent {
  final String name;
  final String email;
  final String phone;

  const UpdateUserProfile({required this.name, required this.email, required this.phone});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateUserProfile &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          phone == other.phone;

  @override
  int get hashCode => name.hashCode ^ email.hashCode ^ phone.hashCode;
}

/// Event triggered when the user submits their phone number to receive an OTP.
class SendOTPCode extends AuthEvent {
  final String phone;

  const SendOTPCode(this.phone);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SendOTPCode &&
          runtimeType == other.runtimeType &&
          phone == other.phone;

  @override
  int get hashCode => phone.hashCode;
}

/// Event triggered when the user inputs and submits the 4-digit verification code.
class VerifyOTPCode extends AuthEvent {
  final String phone;
  final String code;
  final String role;

  const VerifyOTPCode(this.phone, this.code, {this.role = 'passenger'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyOTPCode &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          code == other.code &&
          role == other.role;

  @override
  int get hashCode => phone.hashCode ^ code.hashCode ^ role.hashCode;
}

/// Event triggered when the countdown timer expires and the user requests a code resend.
class ResendOTPCode extends AuthEvent {
  final String phone;

  const ResendOTPCode(this.phone);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResendOTPCode &&
          runtimeType == other.runtimeType &&
          phone == other.phone;

  @override
  int get hashCode => phone.hashCode;

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