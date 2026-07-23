import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';

/// RoleSelectionPage — Shown after a successful OTP login if the user holds
/// both a Passenger and Captain profile. Allows them to choose their session context.
class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.switch_account_rounded,
                    color: Color(0xFFFF6B00),
                    size: 40,
                  ),
                ),
                AppSpacing.h24,
                Text(
                  'أهلاً بك مجدداً',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h12,
                Text(
                  'لقد قمت بتسجيل الدخول بنجاح. يرجى اختيار الواجهة التي ترغب بالدخول إليها:',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    height: 1.5,
                  ),
                ),
                AppSpacing.h48,

                // Passenger Role
                _buildRoleCard(
                  context: context,
                  isDark: isDark,
                  title: 'واجهة الراكب',
                  subtitle: 'طلب رحلات، إرسال طرود، إدارة محفظتك',
                  icon: Icons.person_rounded,
                  route: LaffahRoutes.passengerHome,
                  color: const Color(0xFF3B82F6),
                ),
                
                AppSpacing.h16,
                
                // Captain Role
                _buildRoleCard(
                  context: context,
                  isDark: isDark,
                  title: 'واجهة الكابتن',
                  subtitle: 'استقبال طلبات، تتبع أرباحك اليومية',
                  icon: Icons.two_wheeler_rounded,
                  route: LaffahRoutes.captainHome,
                  color: const Color(0xFFFF6B00),
                ),
              ],
            ),
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
    required String route,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: AppSpacing.radiusLG,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: AppSpacing.radiusLG,
            border: Border.all(
              color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: isDark ? AppColors.gray600 : AppColors.gray400, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
