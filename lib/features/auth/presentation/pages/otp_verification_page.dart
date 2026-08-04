import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_logo.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// OTPVerificationPage - Custom high-fidelity screen to enter 4-digit SMS verification.
/// Features high-contrast auto-focus numeric tiles, a resilient 60s resend timer,
/// and quick "تعديل رقم الهاتف" navigation trigger.
class OTPVerificationPage extends StatefulWidget {
  final String phoneNumber;
  final String role;

  const OTPVerificationPage({
    super.key,
    required this.phoneNumber,
    this.role = 'passenger',
  });

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final List<TextEditingController> _controllers = List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  int _countdownSeconds = 60;
  Timer? _countdownTimer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Auto-focus first tile on entry
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _focusNodes[0].requestFocus();
      }
    });
  }

  void _startTimer() {
    setState(() {
      _countdownSeconds = 60;
      _canResend = false;
    });
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_countdownSeconds > 0) {
            _countdownSeconds--;
          } else {
            _canResend = true;
            _countdownTimer?.cancel();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleVerify() {
    final String otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length == 4) {
      context.read<AuthBloc>().add(VerifyOTPCode(widget.phoneNumber, otpCode, role: widget.role));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'يرجى ملء جميع خانات الرمز المكون من 4 أرقام',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
          ),
        ),
      );
    }
  }

  void _handleResend() {
    if (_canResend) {
      context.read<AuthBloc>().add(ResendOTPCode(widget.phoneNumber));
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'تمت إعادة إرسال الرمز بنجاح لراحة تنقلك',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic', fontSize: 13),
          ),
        ),
      );
    }
  }

  void _onTileChanged(int index, String value) {
    if (value.isNotEmpty) {
      // Advance focus
      if (index < 3) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Automatically attempt verification when last tile is filled
        _focusNodes[index].unfocus();
        _handleVerify();
      }
    }
  }

  void _onTileBackspace(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL support
      child: Scaffold(
appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            'تأكيد الحساب',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthCodeSent) {
                if (state.verificationId != 'register_flow' && state.verificationId.isNotEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF10B981),
                      behavior: SnackBarBehavior.floating,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      content: Text(
                        'كود التحقق للتجربة: ${state.verificationId}',
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      duration: const Duration(seconds: 10),
                    ),
                  );
                }
              } else if (state is AuthSuccess) {
                // Navigate to the correct home based on user role
                if (state.role == 'captain') {
                  context.go(LaffahRoutes.captainHome);
                } else {
                  context.go(LaffahRoutes.passengerHome);
                }
              } else if (state is AuthFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.danger,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderMD,
                    ),
                    content: Text(
                      state.message,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
                // Highlight and clear tiles
                for (var controller in _controllers) {
                  controller.clear();
                }
                _focusNodes[0].requestFocus();
              }
            },
            builder: (context, state) {
              final bool isLoading = state is AuthLoading;

              return Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                    vertical: AppSpacing.s16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Header Branding
                      const LaffahLogo(
                        height: 100,
                        width: 100,
                        showSubtitle: false,
                      ),
                      AppSpacing.h8,
                      Text(
                        'أدخل رمز التحقق',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                      AppSpacing.h4,
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          Text(
                            'أرسلنا رمز تحقق SMS مكون من 4 أرقام إلى ',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              color: isDark ? AppColors.gray500 : AppColors.gray600,
                            ),
                          ),
                          Text(
                            widget.phoneNumber,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ],
                      ),
                      
                      // Edit phone number link
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.edit_rounded, size: 14, color: Color(0xFFFF6B00)),
                        label: const Text(
                          'تعديل رقم الهاتف',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 12.5,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Glassbox Verification Container
                      GlassBox(
                        borderRadius: AppSpacing.radiusXL,
                        padding: const EdgeInsets.all(AppSpacing.s24),
                        child: Column(
                          children: [
                            // Auto-focus OTP input tiles row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              textDirection: TextDirection.ltr, // Input digits display from left-to-right
                              children: List.generate(4, (index) {
                                return SizedBox(
                                  width: 56,
                                  height: 60,
                                  child: RawKeyboardListener(
                                    focusNode: FocusNode(skipTraversal: true), // dedicated node to catch backspaces safely
                                    onKey: (event) => _onTileBackspace(index, event),
                                    child: TextFormField(
                                      controller: _controllers[index],
                                      focusNode: _focusNodes[index],
                                      keyboardType: TextInputType.number,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: isDark ? AppColors.white : AppColors.gray900,
                                      ),
                                      inputFormatters: [
                                        LengthLimitingTextInputFormatter(1),
                                        FilteringTextInputFormatter.digitsOnly,
                                      ],
                                      onChanged: (value) => _onTileChanged(index, value),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
                                        contentPadding: EdgeInsets.zero,
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: AppSpacing.borderMD,
                                          borderSide: BorderSide(
                                            color: isDark ? AppColors.white.withValues(alpha: 0.08) : AppColors.gray300,
                                            width: 1.2,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: AppSpacing.borderMD,
                                          borderSide: const BorderSide(
                                            color: Color(0xFFFF6B00),
                                            width: 2.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),

                            const SizedBox(height: 24),

                            // Dynamic resend timer row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 16,
                                  color: _canResend ? const Color(0xFFFF6B00) : AppColors.gray500,
                                ),
                                const SizedBox(width: AppSpacing.s8),
                                _canResend
                                    ? GestureDetector(
                                        onTap: _handleResend,
                                        child: const Text(
                                          'إعادة إرسال رمز التحقق',
                                          style: TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFFF6B00),
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'إعادة إرسال الرمز خلال $_countdownSeconds ثانية',
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 12.5,
                                          color: isDark ? AppColors.gray500 : AppColors.gray600,
                                        ),
                                      ),
                              ],
                            ),

                            const SizedBox(height: 28),

                            // Submit Verification Button
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _handleVerify,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B00),
                                  foregroundColor: AppColors.white,
                                  elevation: 2,
                                  shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: AppSpacing.borderMD,
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: AppColors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Text(
                                        'تأكيد وتسجيل الدخول',
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontWeight: FontWeight.w900,
                                          fontSize: 14,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),


                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
