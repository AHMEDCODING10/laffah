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

  const HomeTopHeader({
    super.key,
    required this.isDark,
    required this.dropoffController,
    required this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        top: AppSpacing.s24, // Added more top padding for safe area clearance
        bottom: AppSpacing.s8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left (RTL End): Notifications
          Expanded(
            child: GestureDetector(
              onTap: onSearchTap,
              child: GlassBox(
                borderRadius: BorderRadius.circular(24),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            : 'إلى أين؟',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: dropoffController.text.isNotEmpty
                              ? (isDark ? AppColors.white : AppColors.gray900)
                              : (isDark ? AppColors.gray400 : AppColors.gray600),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          AppSpacing.w12,

          // Left (RTL End): Notifications
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              onPressed: () {
                context.push(LaffahRoutes.passengerNotifications);
              },
            ),
          ),
        ],
      ),
    );
  }
}
