import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// ProfileUserHeader — User Info Header Card matching Laffah design specs.
class ProfileUserHeader extends StatelessWidget {
  final bool isDark;
  final String userName;
  final String userPhone;
  final double rating;
  final String membershipTier;
  final VoidCallback? onEditPressed;

  const ProfileUserHeader({
    super.key,
    required this.isDark,
    required this.userName,
    required this.userPhone,
    this.rating = 4.95,
    this.membershipTier = 'عضو ذهبي',
    this.onEditPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusXL,
      padding: const EdgeInsets.all(AppSpacing.s20),
      child: Row(
        children: [
          // Avatar with badge
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary500.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppColors.white,
                  size: 34,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.white,
                    size: 10,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.w16,
          // User Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        userName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ),
                    AppSpacing.w8,
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.12),
                        borderRadius: AppSpacing.borderXS,
                      ),
                      child: Text(
                        membershipTier,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary500,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h4,
                Text(
                  userPhone,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                AppSpacing.h6,
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toStringAsFixed(2),
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: isDark ? AppColors.white : AppColors.gray800,
                      ),
                    ),
                    Text(
                      ' (تقييم الراكب)',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        color: isDark ? AppColors.gray500 : AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onEditPressed != null)
            IconButton(
              icon: const Icon(
                Icons.edit_outlined,
                color: AppColors.primary500,
                size: 20,
              ),
              onPressed: onEditPressed,
            ),
        ],
      ),
    );
  }
}
