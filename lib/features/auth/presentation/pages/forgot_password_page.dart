import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// ForgotPasswordPage — Secure password reset flow for Captains (Passengers use OTP only).
/// Focuses on matching Laffah's dark theme and large touch targets for easy usage on the road.
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  void _handleResetRequest() {
    if (_phoneController.text.trim().length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'يرجى إدخال رقم هاتف صحيح مكون من 9 خانات',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => _isLoading = false);
      // Usually would navigate to OTP verification for reset here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم إرسال كود استعادة كلمة المرور',
            style: TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppSpacing.h24,
                Text(
                  'نسيت كلمة المرور؟',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h12,
                Text(
                  'أدخل رقم هاتفك المسجل في لَفَّة وسنرسل لك رمزاً لإعادة تعيين كلمة المرور.',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    height: 1.5,
                  ),
                ),
                AppSpacing.h40,
                
                // Phone Field
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.white.withOpacity(0.03) : AppColors.gray50,
                    borderRadius: AppSpacing.radiusMD, // ✅ تم التصحيح هنا
                    border: Border.all(
                      color: isDark ? AppColors.white.withOpacity(0.1) : AppColors.gray300,
                    ),
                  ),

                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: 4),
                  child: Row(
                    children: [
                      const Text(
                        '+967',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                      AppSpacing.w12,
                      Container(width: 1, height: 24, color: AppColors.gray400.withOpacity(0.5)),
                      AppSpacing.w12,
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isDark ? AppColors.white : AppColors.gray900,
                            letterSpacing: 2,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '77XXXXXXX',
                            hintStyle: TextStyle(
                              color: isDark ? AppColors.gray600 : AppColors.gray400,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleResetRequest,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD, // ✅ تم التعديل: تمرير الكائن مباشرة
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'إرسال الرمز',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                  ),
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
