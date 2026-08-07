import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// LaffahAppBar — Unified AppBar for the 4 root shell tabs (Home, History, Wallet, Profile).
/// Strictly excludes back arrow button.
/// Contains:
/// - Right (RTL start): Hamburger menu icon (opens side drawer)
/// - Center/Start: Screen Title with bold typography
/// - Left (RTL end): Quick notifications bell icon
class LaffahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuPressed;
  final VoidCallback? onNotificationPressed;
  final bool showMenuButton;
=======
import '../theme/app_colors.dart';

class LaffahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showMenuButton;
  final List<Widget>? actions;
>>>>>>> origin/admin-ahmed

  const LaffahAppBar({
    super.key,
    required this.title,
<<<<<<< HEAD
    this.onMenuPressed,
    this.onNotificationPressed,
    this.showMenuButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.s16,
            vertical: AppSpacing.s8,
          ),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.backgroundDark.withValues(alpha: 0.95)
                : AppColors.backgroundLight.withValues(alpha: 0.95),
          ),
          child: Row(
            children: [
              if (showMenuButton) ...[
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
                    onPressed: onMenuPressed ??
                        () {
                          Scaffold.of(context).openDrawer();
                        },
                  ),
                ),
                AppSpacing.w12,
              ],

              // Screen Title
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),

              const Spacer(),

              // Quick Notifications Link Icon (RTL -> Left side)
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
                    Icons.notifications_outlined,
                    color: AppColors.primary500,
                    size: 22,
                  ),
                  onPressed: onNotificationPressed ??
                      () {
                        context.push(LaffahRoutes.passengerNotifications);
                      },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
=======
    this.showMenuButton = true,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontWeight: FontWeight.bold,
          color: AppColors.primary500,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.primary500),
      leading: showMenuButton
          ? IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            )
          : const BackButton(),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
>>>>>>> origin/admin-ahmed
}
