import '../../../../l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/primary_gradient_button.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// ForgotPasswordPage — Secure password reset flow for Captains (Passengers use OTP only).
/// Focuses on matching Laffah's dark theme and large touch targets for easy usage on the road.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isPhoneFocused = false;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  void _handleResetRequest() {
    if (_phoneController.text.trim().length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.auth_val_phone_9_digits,
            style: const TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final phone = _phoneController.text.trim();
    context.read<AuthBloc>().add(ForgotPasswordRequested(phone: phone));
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    _entranceController.dispose();
    super.dispose();
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
            } else if (state is ForgotPasswordCodeSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      AppLocalizations.of(context)!.auth_pass_reset_sent,
                      style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold)),
                  backgroundColor: AppColors.success,
                ),
              );
              // Navigate to OTP page
              context.push('/auth/forgot-password/otp', extra: state.phone);
            }
          },
          child: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppSpacing.h24,
                      Text(
                        AppLocalizations.of(context)!.auth_forgot_password,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      AppSpacing.h12,
                      Text(
                        AppLocalizations.of(context)!.auth_reset_pass_desc,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 14,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          height: 1.5,
                        ),
                      ),
                      AppSpacing.h40,

                      // Phone Field
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: AppSpacing.borderSM,
                          boxShadow: [
                            if (_isPhoneFocused)
                              BoxShadow(
                                color: const Color(0xFFFF6B00)
                                    .withValues(alpha: 0.12),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.5,
                          ),
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(9),
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            hintText: '7XXXXXXXX',
                            hintStyle: TextStyle(
                              fontFamily: 'monospace',
                              letterSpacing: 1.0,
                              fontSize: 15,
                              color: isDark
                                  ? AppColors.gray600
                                  : AppColors.gray400,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.s16, vertical: 14),
                            filled: true,
                            fillColor: isDark
                                ? AppColors.white.withValues(alpha: 0.02)
                                : AppColors.gray50,
                            suffixIcon: Icon(
                              Icons.phone_iphone_rounded,
                              color: _isPhoneFocused
                                  ? const Color(0xFFFF6B00)
                                  : AppColors.gray600,
                              size: 20,
                            ),
                            prefixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: AppSpacing.s16),
                                const Text(
                                  '+967',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.w900,
                                    fontSize: 15,
                                    color: Color(0xFFFF6B00),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                Container(
                                  height: 22,
                                  width: 1,
                                  color: isDark
                                      ? AppColors.white.withValues(alpha: 0.1)
                                      : AppColors.gray300,
                                ),
                                const SizedBox(width: AppSpacing.s12),
                              ],
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppSpacing.borderSM,
                              borderSide: BorderSide(
                                color: isDark
                                    ? AppColors.white.withValues(alpha: 0.05)
                                    : AppColors.gray300,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide(
                                color: Color(0xFFFF6B00),
                                width: 1.8,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Submit Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return PrimaryGradientButton(
                            text: AppLocalizations.of(context)!.auth_send_code,
                            isLoading: state is AuthLoading,
                            onPressed: state is AuthLoading
                                ? () {}
                                : _handleResetRequest,
                          );
                        },
                      ),
                      AppSpacing.h32,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
    );
  }
}
