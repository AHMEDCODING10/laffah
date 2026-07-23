import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

/// Initial state of the Auth flow.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state for network transitions and async processes.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State emitted when the OTP has been successfully sent to the phone.
class AuthCodeSent extends AuthState {
  final String phone;
  final String verificationId; // Mock verification ID

  const AuthCodeSent({
    required this.phone,
    required this.verificationId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthCodeSent &&
          runtimeType == other.runtimeType &&
          phone == other.phone &&
          verificationId == other.verificationId;

  @override
  int get hashCode => phone.hashCode ^ verificationId.hashCode;
}

/// State emitted when the OTP is successfully verified.
class AuthSuccess extends AuthState {
  const AuthSuccess();
}

/// State emitted when any error or validation failure occurs.
class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthFailure &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
