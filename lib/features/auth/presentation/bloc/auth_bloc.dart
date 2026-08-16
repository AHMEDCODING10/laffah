import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_passenger_usecase.dart';
import '../../domain/usecases/register_captain_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc — Clean Architecture auth state management.
/// Handles Login (phone + password), Register Passenger, Register Captain, Logout.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterPassengerUseCase registerPassengerUseCase;
  final RegisterCaptainUseCase registerCaptainUseCase;
  final AuthRepository authRepository;

  AuthBloc({
    required this.loginUseCase,
    required this.registerPassengerUseCase,
    required this.registerCaptainUseCase,
    required this.authRepository,
  }) : super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterPassengerRequested>(_onRegisterPassengerRequested);
    on<RegisterCaptainRequested>(_onRegisterCaptainRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<ForgotPasswordRequested>(_onForgotPasswordRequested);
    on<VerifyResetCodeRequested>(_onVerifyResetCodeRequested);
    on<ResetPasswordRequested>(_onResetPasswordRequested);
  }

  // ─────────────────────────────────────────────
  // LOGIN
  // ─────────────────────────────────────────────
  FutureOr<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase.call(
      phone: event.phone,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (userEntity) => emit(AuthSuccess(role: userEntity.role)),
    );
  }

  // ─────────────────────────────────────────────
  // REGISTER PASSENGER
  // ─────────────────────────────────────────────
  FutureOr<void> _onRegisterPassengerRequested(
    RegisterPassengerRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerPassengerUseCase.call(
      name: event.name,
      phone: event.phone,
      password: event.password,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (userEntity) => emit(const AuthSuccess(role: 'passenger')),
    );
  }

  // ─────────────────────────────────────────────
  // REGISTER CAPTAIN
  // ─────────────────────────────────────────────
  FutureOr<void> _onRegisterCaptainRequested(
    RegisterCaptainRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerCaptainUseCase.call(
      name: event.name,
      phone: event.phone,
      password: event.password,
      vehicleType: event.vehicleType,
      vehicleModel: event.vehicleModel,
      vehicleYear: event.vehicleYear,
      vehiclePlate: event.vehiclePlate,
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (userEntity) => emit(const AuthSuccess(role: 'captain')),
    );
  }

  // ─────────────────────────────────────────────
  // LOGOUT
  // ─────────────────────────────────────────────
  FutureOr<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    await authRepository.logout();
    emit(const AuthInitial());
  }

  // ─────────────────────────────────────────────
  // FORGOT PASSWORD
  // ─────────────────────────────────────────────
  FutureOr<void> _onForgotPasswordRequested(
    ForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.forgotPassword(event.phone);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(ForgotPasswordCodeSent(phone: event.phone)),
    );
  }

  FutureOr<void> _onVerifyResetCodeRequested(
    VerifyResetCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result =
        await authRepository.verifyResetCode(event.phone, event.code);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(VerifyResetCodeSuccess(phone: event.phone, code: event.code)),
    );
  }

  FutureOr<void> _onResetPasswordRequested(
    ResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await authRepository.resetPassword(
        event.phone, event.code, event.newPassword);
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const ResetPasswordSuccess()),
    );
  }
}
