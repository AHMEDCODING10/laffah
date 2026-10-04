import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  final String phone;
  final String code;

  const ResetPasswordPage({super.key, required this.phone, required this.code});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _resetPassword() {
    if (_passwordController.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.auth_val_pass_8,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.auth_val_pass_mismatch_2,
              style: const TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold)),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(ResetPasswordRequested(
          phone: widget.phone,
          code: widget.code,
          newPassword: _passwordController.text,
        ));
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
            } else if (state is ResetPasswordSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.auth_pass_set_success,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.success,
                ),
              );
              context.go('/auth'); // Back to auth landing
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
                    AppLocalizations.of(context)!.auth_set_password,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h12,
                  Text(
                    AppLocalizations.of(context)!.auth_enter_new_pass,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 14,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                      height: 1.5,
                    ),
                  ),
                  AppSpacing.h40,

                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: 'كلمة المرور الجديدة',
                      hintStyle: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? AppColors.gray600 : AppColors.gray400,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.white.withValues(alpha: 0.05)
                          : AppColors.gray50,
                      prefixIcon: Icon(Icons.lock_outline_rounded,
                          color:
                              isDark ? AppColors.gray500 : AppColors.gray400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: isDark ? AppColors.gray500 : AppColors.gray400,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
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

                  AppSpacing.h16,

                  // Confirm Password Field
                  TextFormField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.auth_confirm_password.replaceAll(':', ''),
                      hintStyle: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        color: isDark ? AppColors.gray600 : AppColors.gray400,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.white.withValues(alpha: 0.05)
                          : AppColors.gray50,
                      prefixIcon: Icon(Icons.lock_outline_rounded,
                          color:
                              isDark ? AppColors.gray500 : AppColors.gray400),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: isDark ? AppColors.gray500 : AppColors.gray400,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
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

                  const Spacer(),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryGradientButton(
                        text:
                            AppLocalizations.of(context)!.auth_change_password,
                        isLoading: state is AuthLoading,
                        onPressed:
                            state is AuthLoading ? null : _resetPassword,
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
