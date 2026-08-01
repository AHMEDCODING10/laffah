import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/laffah_app_bar.dart';

/// UserProfilePage — Restructured to match Stitch design.
/// Sections:
///   1) User info header card (UNCHANGED)
///   2) المعلومات الشخصية  (Profile, Edit Data, Saved Places)
///   3) الأمان والتفضيلات  (Change Password, Language, Dark Mode toggle)
///   4) الدعم والقانون     (Help, FAQ, Contact Us, Privacy, Terms)
///   5) Logout button
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: const LaffahAppBar(title: 'الملف الشخصي', showMenuButton: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.s20, AppSpacing.s16, AppSpacing.s20, 100),
          children: [
            // ══════════════════════════════════════════
            // MODULE 1: User Info Header Card — UNCHANGED
            // ══════════════════════════════════════════
            _buildUserInfoHeader(isDark),

            AppSpacing.h24,

            // ══════════════════════════════════════════
            // MODULE 2: المعلومات الشخصية
            // ══════════════════════════════════════════
            _buildSectionLabel('المعلومات الشخصية', isDark),
            AppSpacing.h10,
            _buildSectionCard(isDark, [
              _ProfileListTile(
                icon: Icons.person_outline_rounded,
                label: 'الملف الشخصي',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.passengerProfile),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.edit_outlined,
                label: 'تعديل البيانات',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.passengerProfileEdit),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.place_outlined,
                label: 'الأماكن المحفوظة',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.passengerSavedPlaces),
              ),
            ]),

            AppSpacing.h20,

            // ══════════════════════════════════════════
            // MODULE 3: الأمان والتفضيلات
            // ══════════════════════════════════════════
            _buildSectionLabel('الأمان والتفضيلات', isDark),
            AppSpacing.h10,
            _buildSectionCard(isDark, [
              _ProfileListTile(
                icon: Icons.lock_outline_rounded,
                label: 'تغيير كلمة المرور',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.changePassword),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.language_rounded,
                label: 'اللغة',
                isDark: isDark,
                trailing: Text(
                  'العربية',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray500,
                  ),
                ),
                onTap: () {
                  // TODO: Implement language switching when multi-language is supported
                },
              ),
              _buildDivider(isDark),
              // Dark mode toggle — functional via ThemeController
              _buildDarkModeTile(isDark),
            ]),

            AppSpacing.h20,

            // ══════════════════════════════════════════
            // MODULE 4: الدعم والقانون
            // ══════════════════════════════════════════
            _buildSectionLabel('الدعم والقانون', isDark),
            AppSpacing.h10,
            _buildSectionCard(isDark, [
              _ProfileListTile(
                icon: Icons.help_outline_rounded,
                label: 'مركز المساعدة',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.helpCenter),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.quiz_outlined,
                label: 'الأسئلة الشائعة',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.faq),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.mail_outline_rounded,
                label: 'تواصل معنا',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.contactUs),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.privacy_tip_outlined,
                label: 'سياسة الخصوصية',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.privacyPolicy),
              ),
              _buildDivider(isDark),
              _ProfileListTile(
                icon: Icons.description_outlined,
                label: 'الشروط والأحكام',
                isDark: isDark,
                onTap: () => context.push(LaffahRoutes.termsOfService),
              ),
            ]),

            AppSpacing.h24,

            // ══════════════════════════════════════════
            // MODULE 5: Logout Button
            // ══════════════════════════════════════════
            _buildLogoutButton(isDark),

            AppSpacing.h32,

            // App version footer
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

            AppSpacing.h24,
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MODULE 1: User Info Header Card — UNTOUCHED from original
  // ─────────────────────────────────────────────────────────────
  Widget _buildUserInfoHeader(bool isDark) {
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
                child: const CircleAvatar(
                  radius: 45,
                  backgroundColor: AppColors.primary50,
                  child: Text(
                    'س',
                    style: TextStyle(
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
                'سارة العامري',
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
                child: const Text(
                  'عميل مميز ★',
                  style: TextStyle(
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

          Text(
            '+967 777 123 456',
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

  // ─────────────────────────────────────────────────────────────
  // HELPERS
  // ─────────────────────────────────────────────────────────────

  /// Section heading label
  Widget _buildSectionLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.s4, bottom: AppSpacing.s2),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w900,
          fontSize: 13,
          letterSpacing: 0.2,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      ),
    );
  }

  /// Rounded card container wrapping a list of tiles
  Widget _buildSectionCard(bool isDark, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.surfaceDark.withValues(alpha: 0.6)
            : AppColors.white.withValues(alpha: 0.9),
        borderRadius: AppSpacing.borderXL,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.12 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: AppSpacing.borderXL,
        child: Column(children: children),
      ),
    );
  }

  /// Thin divider between tiles
  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 52.0,
      color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray100,
    );
  }

  /// Dark Mode toggle tile — functional via ThemeController
  Widget _buildDarkModeTile(bool isDark) {
    final bool isDarkMode = ThemeController.instance.isDarkMode;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s2,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primary500.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.dark_mode_outlined,
          color: AppColors.primary500,
          size: 20,
        ),
      ),
      title: Text(
        'الوضع الداكن',
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: isDark ? AppColors.white : AppColors.gray900,
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

  /// Logout button — prominent, with confirmation dialog
  Widget _buildLogoutButton(bool isDark) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.s14,
          horizontal: AppSpacing.s20,
        ),
        decoration: BoxDecoration(
          color: AppColors.danger.withValues(alpha: isDark ? 0.12 : 0.07),
          borderRadius: AppSpacing.borderXL,
          border: Border.all(
            color: AppColors.danger.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.danger,
              size: 20,
            ),
            AppSpacing.w10,
            const Text(
              'تسجيل الخروج',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LOGOUT DIALOG
  // ─────────────────────────────────────────────────────────────
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
              height: 1.6,
              color: AppColors.gray600,
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.gray700
                            : AppColors.gray300,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderXS,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
                    ),
                    child: const Text(
                      'إلغاء',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      // Navigate to auth landing after logout
                      context.go(LaffahRoutes.authLanding);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
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
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// REUSABLE: _ProfileListTile
// A single, consistent row: leading icon circle + label + trailing widget (arrow or custom)
// ─────────────────────────────────────────────────────────────
class _ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Color iconColor;
  final Widget? trailing;

  const _ProfileListTile({
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.iconColor = AppColors.primary500,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s12,
        ),
        child: Row(
          children: [
            // Leading icon circle
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 19,
              ),
            ),
            AppSpacing.w12,
            // Label
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            // Trailing: custom widget OR default chevron arrow
            trailing ??
                Icon(
                  Icons.chevron_left_rounded, // Left chevron = forward in RTL
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}
