import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/glass_box.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

/// UserProfilePage - Premium, high-fidelity profile screen for Laffah passengers.
/// Strictly implements RTL layouts, IBM Plex Sans Arabic typography, and a modern dark/light styling.
/// Displays user info, gold/silver tiers, document verification cards, and a modern options list.
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProfileBloc>().add(GetProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
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
            'الملف الشخصي',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s16),
              children: [
                // ==========================================
                // MODULE 1: Elegant User Info Header Card
                // ==========================================
                _buildUserInfoHeader(isDark, state),
                
                AppSpacing.h24,

                // ==========================================
                // MODULE 2: Account Level & Streaks
                // ==========================================
                _buildTierMetrics(isDark),

                AppSpacing.h24,

                // ==========================================
                // MODULE 3: Account Verification / Documents
                // ==========================================
                _buildDocumentVerificationSection(isDark),

                AppSpacing.h24,

                // ==========================================
                // MODULE 4: Menu Options & Settings List
                // ==========================================
                _buildMenuOptionsSection(isDark),

                AppSpacing.h40,

            // App Version Footer
            Center(
              child: Column(
                children: [
                  Text(
                    'لَفَّة - تطبيق العميل الموثق',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gray600 : AppColors.gray400,
                    ),
                  ),
                  AppSpacing.h4,
                  Text(
                    'إصدار النسخة: V2.4.0',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.gray700 : AppColors.gray500,
                    ),
                  ),
                ],
              ),
            ),
                AppSpacing.h32,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader(bool isDark, ProfileState state) {
    String name = 'مستخدم لَفَّة';
    String phone = '';
    String roleText = 'عميل مميز ★';
    String initial = 'م';

    if (state is ProfileLoaded) {
      name = state.profile.name.isNotEmpty ? state.profile.name : 'مستخدم لَفَّة';
      phone = state.profile.phone.isNotEmpty ? state.profile.phone : '';
      initial = name.substring(0, 1).toUpperCase();
      roleText = state.profile.role == 'captain' ? 'كابتن لَفَّة ★' : 'عميل مميز ★';
    }

    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Column(
        children: [
          // Dynamic profile avatar with online verification indicator ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary500,
                    width: 3.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.2),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primary50,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 38,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s6),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.white,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
          
          AppSpacing.h16,

          // User details
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.w8,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s10, vertical: AppSpacing.s4),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  roleText,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 9,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          
          AppSpacing.h6,

          if (phone.isNotEmpty)
            Text(
              phone,
              style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTierMetrics(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: GlassBox(
            padding: const EdgeInsets.all(AppSpacing.s12),
            borderRadius: AppSpacing.radiusMD,
            child: Column(
              children: [
                const Text(
                  'الرحلات المكتملة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
                AppSpacing.h6,
                Text(
                  '48 مشوار',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ],
            ),
          ),
        ),
        AppSpacing.w12,
        Expanded(
          child: GlassBox(
            padding: const EdgeInsets.all(AppSpacing.s12),
            borderRadius: AppSpacing.radiusMD,
            child: Column(
              children: [
                const Text(
                  'التقييم الشخصي',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: AppColors.gray500,
                  ),
                ),
                AppSpacing.h6,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    AppSpacing.w4,
                    Text(
                      '4.92 / 5',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentVerificationSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.s4),
          child: Text(
            'توثيق الهوية والوثائق الرسمية',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 14,
              color: isDark ? AppColors.white : AppColors.gray800,
            ),
          ),
        ),
        AppSpacing.h12,
        Row(
          children: [
            // Card 1: ID card
            Expanded(
              child: GlassBox(
                borderRadius: AppSpacing.radiusMD,
                padding: const EdgeInsets.all(AppSpacing.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.badge_rounded,
                          color: AppColors.primary500,
                          size: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'مقبول ✓',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h16,
                    Text(
                      'بطاقة الهوية الوطنية',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    AppSpacing.h4,
                    const Text(
                      'تم التحقق والتوثيق بنجاح',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.w12,
            // Card 2: Driver's license
            Expanded(
              child: GlassBox(
                borderRadius: AppSpacing.radiusMD,
                padding: const EdgeInsets.all(AppSpacing.s12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.card_membership_rounded,
                          color: AppColors.primary500,
                          size: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'تحت المراجعة ⏱️',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 9,
                              color: AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h16,
                    Text(
                      'رخصة القيادة الرسمية',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    AppSpacing.h4,
                    const Text(
                      'جاري التحقق من مكتب المرور',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 10,
                        color: AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMenuOptionsSection(bool isDark) {
    return Material(
      color: isDark ? AppColors.surfaceDark.withValues(alpha: 0.6) : AppColors.white.withValues(alpha: 0.8),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderXL,
        side: BorderSide(
          color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200,
        ),
      ),
      child: Column(
          children: [
            _buildProfileTile(
              icon: Icons.account_balance_wallet_rounded,
              title: 'محفظتي وطرق الدفع',
              subtitle: 'الرصيد المتاح: 4,500 ريال',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.percent_rounded,
              title: 'الأكواد الترويجية',
              subtitle: 'وفر أجرة مشاويرك مع عروض لَفَّة',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.stars_rounded,
              title: 'الأماكن المفضلة',
              subtitle: 'أضف المنزل، العمل، والوجهات المعتادة',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.support_agent_rounded,
              title: 'الدعم والمساعدة',
              subtitle: 'حلول المشاكل، التذاكر، والتواصل المباشر',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.security_rounded,
              title: 'الأمان والخصوصية',
              subtitle: 'قفل الحساب، تعديل كلمة المرور، وتوثيق المصادقة',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildThemeSwitchTile(isDark),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.language_rounded,
              title: 'لغة التطبيق / Language',
              subtitle: 'العربية (Arabic)',
              isDark: isDark,
              onTap: () {},
            ),
            _buildDivider(isDark),
            _buildProfileTile(
              icon: Icons.power_settings_new_rounded,
              title: 'تسجيل الخروج',
              subtitle: 'تبديل الحساب أو إغلاق الجلسة الحالية',
              iconColor: AppColors.danger,
              isDark: isDark,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
    );
  }

  Widget _buildThemeSwitchTile(bool isDark) {
    final bool isDarkMode = ThemeController.instance.isDarkMode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.s8),
        decoration: BoxDecoration(
          color: AppColors.primary500.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.dark_mode_rounded,
          color: AppColors.primary500,
          size: 20,
        ),
      ),
      title: Text(
        'الوضع الداكن (Dark Mode)',
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      subtitle: Text(
        isDarkMode ? 'الوضع الداكن مفعّل حالياً' : 'الوضع النهاري مفعّل (الافتراضي)',
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: AppColors.gray500,
        ),
      ),
      trailing: Switch(
        value: isDarkMode,
        activeThumbColor: AppColors.primary500,
        onChanged: (val) {
          ThemeController.instance.toggleTheme(val);
          setState(() {});
        },
      ),
    );
  }

  Widget _buildProfileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isDark,
    Color iconColor = AppColors.primary500,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s4),
      leading: Container(
        padding: const EdgeInsets.all(AppSpacing.s8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: iconColor,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 11,
          color: AppColors.gray500,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_left_rounded, // Left chevron because of RTL Arabic UI layout!
        color: AppColors.gray400,
        size: 20,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: AppSpacing.s16,
      endIndent: AppSpacing.s16,
      color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray100,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.surfaceDark
              : AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderLG,
          ),
          title: const Text(
            'تسجيل الخروج',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
          content: const Text(
            'هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك الحالي؟ يمكنك دائمًا تسجيل الدخول مرة أخرى برقم هاتفك والـ OTP.',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  color: AppColors.gray500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                context.go(LaffahRoutes.authLanding); // Go to auth landing page
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderXS,
                ),
              ),
              child: const Text(
                'تأكيد الخروج',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
