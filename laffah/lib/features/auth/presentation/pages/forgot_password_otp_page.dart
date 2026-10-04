import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ForgotPasswordOtpPage extends StatefulWidget {
  final String phone;

  const ForgotPasswordOtpPage({super.key, required this.phone});

  @override
  State<ForgotPasswordOtpPage> createState() => _ForgotPasswordOtpPageState();
}

class _ForgotPasswordOtpPageState extends State<ForgotPasswordOtpPage> {
  final TextEditingController _otpController = TextEditingController();

  void _verifyOtp() {
    final code = _otpController.text.trim();
    if (code.length != 6 && code.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال رمز التحقق المكون من 6 أرقام',
              style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }
    context.read<AuthBloc>().add(VerifyResetCodeRequested(
        phone: widget.phone, code: code));
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : const Color(0xFFF8F9FA),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.danger,
                ),
              );
            } else if (state is VerifyResetCodeSuccess) {
              context.push('/auth/reset-password',
                  extra: {'phone': state.phone, 'code': state.code});
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.h24,
                  Text(
                    AppLocalizations.of(context)!.auth_confirm_code,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h12,
                  Text(
                    'أدخل رمز التحقق الذي تم إرساله إلى ${widget.phone}',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                  AppSpacing.h40,
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      controller: _otpController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 12.0,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(6),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: InputDecoration(
                        hintText: '------',
                        hintStyle: TextStyle(
                          fontSize: 26,
                          letterSpacing: 12.0,
                          color: isDark ? AppColors.gray600 : AppColors.gray400,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.white.withValues(alpha: 0.05)
                            : AppColors.gray50,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 20),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.white.withValues(alpha: 0.1)
                                : AppColors.gray300,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary500,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryGradientButton(
                        text: AppLocalizations.of(context)!.auth_confirm,
                        isLoading: state is AuthLoading,
                        onPressed: state is AuthLoading ? null : _verifyOtp,
                      );
                    },
                  ),
                  AppSpacing.h32,
                ],
              ),
            ),
          ),
        ),
    );
  }
}
