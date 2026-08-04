import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/register_passenger_usecase.dart';
import '../../domain/usecases/register_captain_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc - Manages Authentication State transitions using Clean Architecture
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final RegisterPassengerUseCase registerPassengerUseCase;
  final RegisterCaptainUseCase registerCaptainUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.registerPassengerUseCase,
    required this.registerCaptainUseCase,
  }) : super(const AuthInitial()) {
    on<SendOTPCode>(_onSendOTPCode);
    on<VerifyOTPCode>(_onVerifyOTPCode);
    on<ResendOTPCode>(_onResendOTPCode);
    on<UpdateUserProfile>(_onUpdateUserProfile);
    on<RegisterPassengerRequested>(_onRegisterPassengerRequested);
    on<RegisterCaptainRequested>(_onRegisterCaptainRequested);
  }

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

  FutureOr<void> _onSendOTPCode(
    SendOTPCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendOtpUseCase.call(event.phone);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (verificationId) => emit(AuthCodeSent(
        phone: event.phone,
        verificationId: verificationId,
      )),
    );
  }

  FutureOr<void> _onVerifyOTPCode(
    VerifyOTPCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    
    final String phone = event.phone;

    final result = await verifyOtpUseCase.call(phone, event.code, role: event.role);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (userEntity) => emit(AuthSuccess(role: userEntity.role)),
    );
  }

  FutureOr<void> _onResendOTPCode(
    ResendOTPCode event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await sendOtpUseCase.call(event.phone);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (verificationId) => emit(AuthCodeSent(
        phone: event.phone,
        verificationId: verificationId,
      )),
    );
  }

  FutureOr<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    // Simulate backend save
    await Future.delayed(const Duration(seconds: 1));
    emit(const AuthProfileUpdated());
  }
}
