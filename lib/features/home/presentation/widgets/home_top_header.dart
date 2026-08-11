import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../l10n/app_localizations.dart';

/// HomeTopHeader — Header widget containing screen title ("الرئيسية"),
/// notifications button on side, and interactive destination search bar ("إلى أين؟").
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
    final title = AppLocalizations.of(context)?.capt_nav_home ?? 'الرئيسية';
    final double topSafeArea = MediaQuery.of(context).padding.top;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.s16,
        right: AppSpacing.s16,
        top: topSafeArea > 0 ? topSafeArea + 8 : AppSpacing.s24,
        bottom: AppSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── TOP BAR: Title in Center + Notification Icon on Left Side ───
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Symmetrical Spacer on Right side (RTL Start)
              const SizedBox(width: 44),

              // Title in Middle
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
              ),

              // Notification Icon Button on Left side (RTL End / الشمال)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceElevatedDark : AppColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.primary500, // Primary Orange Color
                    size: 24,
                  ),
                  onPressed: () {
                    context.push(LaffahRoutes.passengerNotifications);
                  },
                ),
              ),
            ],
          ),

          AppSpacing.h16, // Lower search bar down from title bar

          // ─── SEARCH BAR: "إلى أين؟" ───
          GestureDetector(
            onTap: onSearchTap,
            child: GlassBox(
              borderRadius: BorderRadius.circular(24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
        ],
      ),
    );
  }
}
