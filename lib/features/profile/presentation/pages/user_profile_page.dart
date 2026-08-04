import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/laffah_app_bar.dart';
import '../../data/datasources/fake_profile_repository.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../widgets/profile_section_card.dart';
import '../widgets/profile_user_header.dart';

/// UserProfilePage — Refactored Profile Page for Laffah Passengers.
/// Clean Architecture & Modular Widget Composition.
class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  late final Map<String, dynamic> _userData;

  @override
  void initState() {
    super.initState();
    _userData = FakeProfileRepository.getUserProfile();
  }

  void _showLogoutDialog(bool isDark) {
    LogoutConfirmationDialog.show(context, isDark, () {
      context.go(LaffahRoutes.authLanding);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: const LaffahAppBar(title: 'الملف الشخصي', showMenuButton: false),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.s20,
            AppSpacing.s16,
            AppSpacing.s20,
            100,
          ),
          children: [
            // User Header Card
            ProfileUserHeader(
              isDark: isDark,
              userName: _userData['name'],
              userPhone: _userData['phone'],
              rating: _userData['rating'],
              membershipTier: _userData['membershipTier'],
              onEditPressed: () =>
                  context.push(LaffahRoutes.passengerProfileEdit),
            ),

            AppSpacing.h24,

            // Section 1: Personal Info
            ProfileSectionCard(
              isDark: isDark,
              sectionTitle: 'المعلومات الشخصية',
              tiles: [
                ProfileListTile(
                  icon: Icons.person_outline_rounded,
                  label: 'الملف الشخصي',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerProfile),
                ),
                ProfileListTile(
                  icon: Icons.edit_outlined,
                  label: 'تعديل البيانات',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerProfileEdit),
                ),
                ProfileListTile(
                  icon: Icons.place_outlined,
                  label: 'الأماكن المحفوظة',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.passengerSavedPlaces),
                ),
              ],
            ),

            AppSpacing.h20,

            // Section 2: Security & Preferences
            ProfileSectionCard(
              isDark: isDark,
              sectionTitle: 'الأمان والتفضيلات',
              tiles: [
                ProfileListTile(
                  icon: Icons.lock_outline_rounded,
                  label: 'تغيير كلمة المرور',
                  isDark: isDark,
                  onTap: () {}, // TODO: Implement change password page
                ),
                ProfileListTile(
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
                  onTap: () {},
                ),
                ProfileListTile(
                  icon: isDark
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  label: 'الوضع الليلي',
                  isDark: isDark,
                  trailing: Switch(
                    value: isDark,
                    activeThumbColor: AppColors.primary500,
                    onChanged: (val) {
                      ThemeController.instance.toggleTheme(val);
                    },
                  ),
                  onTap: () {
                    ThemeController.instance.toggleTheme(!isDark);
                  },
                ),
              ],
            ),

            AppSpacing.h20,

            // Section 3: Support & Legal
            ProfileSectionCard(
              isDark: isDark,
              sectionTitle: 'الدعم والقانون',
              tiles: [
                ProfileListTile(
                  icon: Icons.headset_mic_outlined,
                  label: 'الدعم الفني والخدمات',
                  isDark: isDark,
                  onTap: () async {
                    final Uri url = Uri.parse('whatsapp://send?phone=+967770291452');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      final Uri phoneUrl = Uri.parse('tel:+967770291452');
                      if (await canLaunchUrl(phoneUrl)) {
                        await launchUrl(phoneUrl);
                      }
                    }
                  },
                ),
                ProfileListTile(
                  icon: Icons.help_outline_rounded,
                  label: 'الأسئلة الشائعة',
                  isDark: isDark,
                  onTap: () {}, // TODO: Implement FAQ page
                ),
                ProfileListTile(
                  icon: Icons.privacy_tip_outlined,
                  label: 'سياسة الخصوصية',
                  isDark: isDark,
                  onTap: () => context.push(LaffahRoutes.privacyPolicy),
                ),
              ],
            ),

            AppSpacing.h24,

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutDialog(isDark),
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 20,
                ),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.danger,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderMD,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
