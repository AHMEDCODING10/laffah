import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../pages/widgets/captain_account_dialogs.dart';
import 'captain_document_upload_page.dart';
import '../../../../core/theme/theme_controller.dart';

import '../../../../core/router/app_router.dart';

/// CaptainSettingsPage — Allows Captain to toggle preferences like navigation app,
/// auto-accept rides, and notification preferences.
class CaptainSettingsPage extends StatefulWidget {
  const CaptainSettingsPage({super.key});

  @override
  State<CaptainSettingsPage> createState() => _CaptainSettingsPageState();
}

class _CaptainSettingsPageState extends State<CaptainSettingsPage> {
  bool _autoAcceptRides = true;
  bool _soundNotifications = true;
  bool _receiveParcels = true;
  final String _selectedNavigationApp = 'خرائط جوجل';

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(LaffahRoutes.captainHome);
              }
            },
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
            _buildSectionHeader('مظهر التطبيق', isDark),
            _buildSwitchTile(
              title: 'الوضع الداكن (Dark Mode)',
              subtitle: 'التبديل بين المظهر النهاري والمظهر الداكن حسب راحتك.',
              icon: Icons.dark_mode_rounded,
              value: ThemeController.instance.isDarkMode,
              onChanged: (val) {
                ThemeController.instance.toggleTheme(val);
                setState(() {});
              },
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
              title: 'التوجيه الصوتي والتنبيهات',
              subtitle: 'تفعيل التعليمات الصوتية والتنبيهات أثناء القيادة.',
              icon: Icons.record_voice_over_rounded,
              value: _soundNotifications,
              onChanged: (val) => setState(() => _soundNotifications = val),
              isDark: isDark,
            ),
            AppSpacing.h16,
            _buildSectionHeader('الحساب والأمان', isDark),
            _buildActionTile(
              title: 'المركبات المسجلة',
              icon: Icons.motorcycle_rounded,
              isDark: isDark,
              onTap: () {
                final l10n = AppLocalizations.of(context)!;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AppColors.primary,
                    content: Text(
                      l10n.capt_multi_vehicle_coming_soon,
                      style: const TextStyle(fontFamily: 'IBM Plex Sans Arabic'),
                    ),
                  ),
                );
              },
            ),
            _buildActionTile(
              title: 'تحديث المستندات (الرخصة/الهوية)',
              icon: Icons.assignment_ind_rounded,
              isDark: isDark,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CaptainDocumentUploadPage(),
                  ),
                );
              },
            ),
            _buildActionTile(
              title: 'تغيير كلمة المرور',
              icon: Icons.lock_rounded,
              isDark: isDark,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) => const ChangePasswordSheet(),
                );
              },
            ),
            AppSpacing.h32,
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
              child: OutlinedButton.icon(
                onPressed: () {
                  final l10n = AppLocalizations.of(context)!;
                  final isDark = Theme.of(context).brightness == Brightness.dark;
                  showDialog(
                    context: context,
                    builder: (ctx) => Directionality(
                      textDirection: TextDirection.rtl,
                      child: Dialog(
                        backgroundColor: Colors.transparent,
                        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF161B26) : Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : AppColors.gray200,
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.08),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: AppColors.error.withValues(alpha: 0.12),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.delete_forever_rounded,
                                  color: AppColors.error,
                                  size: 28,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                l10n.capt_delete_account_dialog_title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                  color: isDark ? Colors.white : AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                l10n.capt_delete_account_dialog_content,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 13,
                                  height: 1.6,
                                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                                ),
                              ),
                              const SizedBox(height: 24),
                              // 1. Delete Button (Red, Full Width)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: AppColors.danger,
                                        content: Text(
                                          l10n.capt_delete_account_request_sent,
                                          style: const TextStyle(
                                            fontFamily: 'IBM Plex Sans Arabic',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.error,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.capt_delete_account_confirm_btn,
                                    style: const TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      fontWeight: FontWeight.w900,
                                      fontSize: 15,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // 2. Cancel Button (Underneath)
                              SizedBox(
                                width: double.infinity,
                                height: 46,
                                child: TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  style: TextButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: Text(
                                    l10n.cancel_btn,
                                    style: TextStyle(
                                      fontFamily: 'IBM Plex Sans Arabic',
                                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                icon: const Icon(Icons.delete_forever_rounded),
                label: Text(
                  AppLocalizations.of(context)!.capt_delete_account_forever,
                  style: const TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 14,
          fontWeight: FontWeight.w900,
          color: AppColors.primary500,
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
      activeThumbColor: AppColors.primary500,
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
      secondary:
          Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
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
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.primary500,
        ),
      ),
      leading:
          Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: isDark ? AppColors.gray600 : AppColors.gray400),
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
      leading:
          Icon(icon, color: isDark ? AppColors.gray400 : AppColors.gray600),
      trailing: Icon(Icons.arrow_forward_ios_rounded,
          size: 16, color: isDark ? AppColors.gray600 : AppColors.gray400),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
    );
  }
}
