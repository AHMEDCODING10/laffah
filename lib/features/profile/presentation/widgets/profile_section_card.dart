import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// Single item tile in profile section card
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
    return InkWell(
      onTap: onTap,
      borderRadius: AppSpacing.radiusSM,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s14,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.s8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.white.withValues(alpha: 0.05)
                    : AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDark ? AppColors.white : AppColors.gray800,
                size: 18,
              ),
            ),
            AppSpacing.w12,
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ),
            if (trailing != null) trailing!,
            if (trailing == null)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: isDark ? AppColors.gray500 : AppColors.gray400,
              ),
          ],
        ),
      ),
    );
  }
}

/// ProfileSectionCard — Section container wrapper for profile tiles
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
              right: AppSpacing.s4, bottom: AppSpacing.s8),
          child: Text(
            sectionTitle,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
        ),
        GlassBox(
          borderRadius: AppSpacing.radiusLG,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                tiles[i],
                if (i < tiles.length - 1)
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.05)
                        : AppColors.gray200,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
