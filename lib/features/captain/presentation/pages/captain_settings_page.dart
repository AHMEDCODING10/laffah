import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// CaptainSettingsPage — Allows Captain to toggle preferences like navigation app,
/// auto-accept rides, and notification preferences.
class CaptainSettingsPage extends StatefulWidget {
  const CaptainSettingsPage({super.key});

  @override
  State<CaptainSettingsPage> createState() => _CaptainSettingsPageState();
}

class _CaptainSettingsPageState extends State<CaptainSettingsPage> {
  bool _autoAcceptRides = false;
  bool _voiceNavigation = true;
  bool _receiveParcels = true;
  String _selectedNavigationApp = 'خرائط جوجل';

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
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'الإعدادات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.s16),
          children: [
            _buildSectionHeader('تفضيلات الرحلات', isDark),
            _buildSwitchTile(
              title: 'القبول التلقائي للطلبات',
              subtitle: 'قبول طلبات الركاب الأقرب إليك تلقائياً لتوفير الوقت.',
              icon: Icons.bolt_rounded,
              value: _autoAcceptRides,
              onChanged: (val) => setState(() => _autoAcceptRides = val),
              isDark: isDark,
            ),
            _buildSwitchTile(
              title: 'استقبال طلبات توصيل الطرود',
              subtitle: 'السماح باستقبال طلبات توصيل الأمانات والطرود.',
              icon: Icons.inventory_2_rounded,
              value: _receiveParcels,
              onChanged: (val) => setState(() => _receiveParcels = val),
              isDark: isDark,
            ),

            AppSpacing.h16,
            _buildSectionHeader('الملاحة والتوجيه', isDark),
            _buildSelectionTile(
              title: 'تطبيق الخرائط المفضل',
              subtitle: _selectedNavigationApp,
              icon: Icons.map_rounded,
              isDark: isDark,
              onTap: () {
                // Show bottom sheet to select map app
              },
            ),
            _buildSwitchTile(
              title: 'التوجيه الصوتي',
              subtitle: 'تفعيل التعليمات الصوتية أثناء القيادة للحفاظ على سلامتك.',
              icon: Icons.record_voice_over_rounded,
              value: _voiceNavigation,
              onChanged: (val) => setState(() => _voiceNavigation = val),
              isDark: isDark,
            ),

            AppSpacing.h16,
            _buildSectionHeader('الحساب والأمان', isDark),
            _buildActionTile(
              title: 'المركبات المسجلة',
              icon: Icons.motorcycle_rounded,
              isDark: isDark,
              onTap: () {},
            ),
            _buildActionTile(
              title: 'تحديث المستندات (الرخصة/الهوية)',
              icon: Icons.assignment_ind_rounded,
              isDark: isDark,
              onTap: () {},
            ),
            _buildActionTile(
              title: 'تغيير كلمة المرور',
              icon: Icons.lock_rounded,
              isDark: isDark,
              onTap: () {},
            ),
            
            AppSpacing.h32,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: OutlinedButton.icon(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            AppSpacing.h32,
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: const Color(0xFFFF6B00),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFF6B00),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 12,
          color: isDark ? AppColors.gray400 : AppColors.gray600,
        ),
      ),
      secondary: Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildSelectionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFFFF6B00),
        ),
      ),
      leading: Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.gray600 : AppColors.gray400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }

  Widget _buildActionTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return ListTile(
      onTap: onTap,
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      leading: Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
      trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16, color: isDark ? AppColors.gray600 : AppColors.gray400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}

