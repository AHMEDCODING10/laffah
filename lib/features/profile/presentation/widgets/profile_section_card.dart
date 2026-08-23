import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// Single item card in profile section
class ProfileListTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  final Widget? trailing;

  const ProfileListTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      margin: const EdgeInsets.only(bottom: 8),
      borderRadius: BorderRadius.circular(16),
      padding: EdgeInsets.zero,
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primary500,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
                if (trailing == null)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 13,
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ProfileSectionCard — Section container wrapper for profile cards
class ProfileSectionCard extends StatelessWidget {
  final bool isDark;
  final String sectionTitle;
  final List<ProfileListTile> tiles;

  const ProfileSectionCard({
    super.key,
    required this.isDark,
    required this.sectionTitle,
    required this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            right: AppSpacing.s4,
            bottom: 8,
          ),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              fontSize: 12.5,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
        Column(
          children: tiles,
        ),
      ],
    );
  }
}
