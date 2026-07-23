import 'package:flutter/foundation.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
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

  const VerifyOTPCode(this.phone, this.code);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyOTPCode &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          code == other.code;

  @override
  int get hashCode => phone.hashCode ^ code.hashCode;
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