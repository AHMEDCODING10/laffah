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
  final String verificationId; // Verification ID returned from API

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
  final String role; // 'captain' or 'passenger'

  const AuthSuccess({this.role = 'passenger'});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthSuccess &&
          runtimeType == other.runtimeType &&
          role == other.role;

  @override
  int get hashCode => role.hashCode;
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

class AuthProfileUpdated extends AuthState {
  const AuthProfileUpdated();
}
