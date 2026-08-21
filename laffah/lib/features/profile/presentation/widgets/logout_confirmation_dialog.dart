import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../l10n/app_localizations.dart';

/// LogoutConfirmationDialog — Displays a side-by-side confirmation modal when logging out.
class LogoutConfirmationDialog extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConfirm;

  const LogoutConfirmationDialog({
    super.key,
    required this.isDark,
    required this.onConfirm,
  });

  static Future<void> show(
      BuildContext context, bool isDark, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (ctx) => LogoutConfirmationDialog(
        isDark: isDark,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s12),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.danger,
                  size: 28,
                ),
              ),
              AppSpacing.h16,
              Text(
                AppLocalizations.of(context)!.logout_confirm_title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h8,
              Text(
                AppLocalizations.of(context)!.logout_confirm_message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 12.5,
                  height: 1.4,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              AppSpacing.h20,
              // Side-by-side buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark ? AppColors.gray600 : AppColors.gray300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.cancel_btn,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isDark ? AppColors.gray300 : AppColors.gray700,
                        ),
                      ),
                    ),
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: AppColors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.confirm_logout_btn,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.white,
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
