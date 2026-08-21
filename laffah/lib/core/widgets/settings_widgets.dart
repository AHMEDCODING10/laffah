import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;

  const SectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerEnd,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.bold,
          color: AppColors.gray500,
          fontFamily: 'IBM Plex Sans Arabic',
        ),
      ),
    );
  }
}

class SettingItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDark;

  const SettingItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Material(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap();
            },
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.gray500,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
          ),
        ),
      ),
    );
  }
}

class SettingSwitchWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const SettingSwitchWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s10),
      child: Material(
        color: isDark
            ? const Color(0xFF141822).withValues(alpha: 0.9)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: SwitchListTile.adaptive(
            value: value,
            onChanged: (val) {
              HapticFeedback.selectionClick();
              onChanged(val);
            },
            activeTrackColor: AppColors.primary500,
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            subtitle: Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.gray500,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),
            secondary: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary500.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary500, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}
