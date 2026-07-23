import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_logo.dart';
import 'phone_number_input_page.dart';
import 'register_passenger_page.dart';
import 'register_captain_page.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';

/// AuthLandingPage - Elegant gateway where passengers and captains begin their Laffah journey.
/// Implements beautiful, high-contrast layouts, Glassmorphic cards, complete RTL support,
/// explicit role routing, and clear "Skip" / "Login" actions.
class AuthLandingPage extends StatelessWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl, // RTL Layout first
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Skip Button at the top-left (or top-right in RTL, let's put it on top-left)
              Positioned(
                top: AppSpacing.s12,
                left: AppSpacing.s16,
                child: TextButton(
                  onPressed: () {
                    // Navigate to home dashboard bypassing authentication via GoRouter
                    context.go(LaffahRoutes.passengerHome);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B00),
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.s16,
                      vertical: AppSpacing.s8,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'تخطي',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.double_arrow_rounded, size: 16),
                    ],
                  ),
                ),
              ),

              // 2. Main Content Scrollable
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s24,
                  vertical: AppSpacing.s40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 48),

                    // Brand Logo Mark
                    const LaffahLogo(
                      height: 120,
                      width: 120,
                      showSubtitle: true,
                    ),

                    const SizedBox(height: 40),

                    // Heading Promo Text
                    Text(
                      'خطوتك الأولى لتنقل ذكي وموثوق',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.gray900,
                        height: 1.3,
                      ),
                    ),

                    AppSpacing.h8,

                    Text(
                      'اختر طريقة انضمامك إلى منصة لَفَّة للبدء بالتنقل أو تحقيق الأرباح في صنعاء وباقي المدن اليمنية.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                        height: 1.5,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // 3. Option 1: Join as Passenger
                    _buildRoleCard(
                      context: context,
                      isDark: isDark,
                      title: 'طلب رحلة (راكب)',
                      subtitle: 'ابحث عن كابتن، احسب أجرتك، وتنقّل بأمان وسهولة بضغطة زر.',
                      icon: Icons.person_pin_circle_rounded,
                      buttonText: 'إنشاء حساب راكب',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPassengerPage(),
                          ),
                        );
                      },
                    ),

                    AppSpacing.h20,

                    // 4. Option 2: Join as Captain
                    _buildRoleCard(
                      context: context,
                      isDark: isDark,
                      title: 'انضم ككابتن (سائق)',
                      subtitle: 'سجّل دراجتك النارية، كُن رئيس نفسك وحقّق عوائد يومية ممتازة.',
                      icon: Icons.two_wheeler_rounded,
                      buttonText: 'التسجيل ككابتن لَفَّة',
                      accentColor: const Color(0xFFFF6B00),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterCaptainPage(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 48),

                    // 5. Existing Account Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14,
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.s8),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhoneNumberInputPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6B00),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onPressed,
    Color accentColor = AppColors.gray900,
  }) {
    final bool isOrangeAccent = accentColor == const Color(0xFFFF6B00);

    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: isOrangeAccent
                      ? const Color(0xFFFF6B00).withOpacity(0.12)
                      : AppColors.primary500.withOpacity(0.08),
                  borderRadius: AppSpacing.borderSM,
                ),
                child: Icon(
                  icon,
                  color: isOrangeAccent ? const Color(0xFFFF6B00) : AppColors.primary500,
                  size: 28,
                ),
              ),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11.5,
                        height: 1.4,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          AppSpacing.h16,
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: isOrangeAccent ? const Color(0xFFFF6B00) : AppColors.gray800,
                foregroundColor: AppColors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderMD,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    buttonText,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  AppSpacing.w8,
                  const Icon(Icons.arrow_back_rounded, size: 16), // Flipped because of RTL
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
