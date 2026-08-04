import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

/// HomeTopHeader — Pinned header widget containing drawer toggle, screen title,
/// quick notifications button, and interactive destination search bar ("إلى أين؟").
class HomeTopHeader extends StatelessWidget {
  final bool isDark;
  final TextEditingController dropoffController;
  final VoidCallback onSearchTap;
  final VoidCallback onOpenDrawer;

  const HomeTopHeader({
    super.key,
    required this.isDark,
    required this.dropoffController,
    required this.onSearchTap,
    required this.onOpenDrawer,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s16,
        vertical: AppSpacing.s8,
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Hamburger Menu Button (RTL -> Right side)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary500.withValues(alpha: 0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.menu_rounded,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  onPressed: onOpenDrawer,
                ),
              ),

              AppSpacing.w12,

              // Title "الرئيسية"
              Text(
                'الرئيسية',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),

              const Spacer(),

              // Notifications Link Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.surfaceElevatedDark
                      : AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.08)
                        : AppColors.gray200,
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.gray700,
                    size: 22,
                  ),
                  onPressed: () {
                    context.push(LaffahRoutes.passengerNotifications);
                  },
                ),
              ),
            ],
          ),

          AppSpacing.h12,

          // Search Bar "إلى أين؟"
          GestureDetector(
            onTap: onSearchTap,
            child: GlassBox(
              borderRadius: AppSpacing.radiusMD,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                  AppSpacing.w12,
                  Expanded(
                    child: Text(
                      dropoffController.text.isNotEmpty
                          ? dropoffController.text
                          : 'إلى أين؟ اختر وجهتك...',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 14,
                        fontWeight: dropoffController.text.isNotEmpty
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: dropoffController.text.isNotEmpty
                            ? (isDark ? AppColors.white : AppColors.gray900)
                            : (isDark ? AppColors.gray500 : AppColors.gray600),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: AppColors.primary500,
                          size: 14,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'الخريطة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
