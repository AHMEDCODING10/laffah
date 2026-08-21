import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {
  const AuthState();
}

/// الحالة الابتدائية.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// حالة التحميل أثناء طلبات الشبكة.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// حالة النجاح بعد تسجيل الدخول أو إنشاء حساب.
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

/// حالة الخطأ عند فشل أي عملية.
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

class ForgotPasswordCodeSent extends AuthState {
  final String phone;
  const ForgotPasswordCodeSent({required this.phone});
}

class VerifyResetCodeSuccess extends AuthState {
  final String phone;
  final String code;
  const VerifyResetCodeSuccess({required this.phone, required this.code});
}

class ResetPasswordSuccess extends AuthState {
  const ResetPasswordSuccess();
}
