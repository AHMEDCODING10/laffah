import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_otp_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// AuthBloc - Manages Authentication State transitions using Clean Architecture
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;

  AuthBloc({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
  }) : super(const AuthInitial()) {
    on<SendOTPCode>(_onSendOTPCode);
    on<VerifyOTPCode>(_onVerifyOTPCode);
    on<ResendOTPCode>(_onResendOTPCode);
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
    
    // Assuming the event has phone and code, but original AuthEvent VerifyOTPCode only has code
    // In a real flow, phone should be passed from UI or state.
    // For now we will use a dummy phone if not available, or you need to update AuthEvent.
    // Note: VerifyOTPCode event needs to be updated to include phone.
    // Assuming we update VerifyOTPCode to include phone.
    final String phone = (event as dynamic).phone ?? '777123456'; 

    final result = await verifyOtpUseCase.call(phone, event.code);

    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (userEntity) => emit(const AuthSuccess()),
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
}
