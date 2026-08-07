<<<<<<< HEAD
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

/// HomeBottomNavBar — Persistent bottom navigation bar for the 4 passenger shell tabs:
/// (0: الرئيسية, 1: رحلاتي, 2: المحفظة, 3: الحساب).
=======
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// HomeBottomNavBar — Ultra-modern, floating glassmorphic navigation dock
/// designed specifically for Laffah Passenger screens, matching the Captain UI.
/// Features iOS-inspired glassmorphism, animated active indicator pills,
/// haptic feedback, and responsive RTL layout.
>>>>>>> origin/admin-ahmed
class HomeBottomNavBar extends StatelessWidget {
  final bool isDark;
  final int currentIndex;

  const HomeBottomNavBar({
    super.key,
    required this.isDark,
    this.currentIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> navItems = [
      {
        'title': 'الرئيسية',
        'icon': Icons.home_rounded,
<<<<<<< HEAD
=======
        'activeIcon': Icons.home_rounded,
>>>>>>> origin/admin-ahmed
        'route': LaffahRoutes.passengerHome,
      },
      {
        'title': 'رحلاتي',
        'icon': Icons.receipt_long_rounded,
<<<<<<< HEAD
=======
        'activeIcon': Icons.receipt_long_rounded,
>>>>>>> origin/admin-ahmed
        'route': LaffahRoutes.passengerHistory,
      },
      {
        'title': 'المحفظة',
        'icon': Icons.account_balance_wallet_rounded,
<<<<<<< HEAD
=======
        'activeIcon': Icons.account_balance_wallet_rounded,
>>>>>>> origin/admin-ahmed
        'route': LaffahRoutes.passengerWallet,
      },
      {
        'title': 'الحساب',
        'icon': Icons.person_rounded,
<<<<<<< HEAD
=======
        'activeIcon': Icons.person_rounded,
>>>>>>> origin/admin-ahmed
        'route': LaffahRoutes.passengerProfile,
      },
    ];

<<<<<<< HEAD
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.08)
                : AppColors.gray200,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(navItems.length, (index) {
          final item = navItems[index];
          final bool isActive = index == currentIndex;
          final Color itemColor = isActive
              ? AppColors.primary500
              : (isDark ? AppColors.gray500 : AppColors.gray600);

          return Expanded(
            child: InkWell(
              onTap: () {
                if (!isActive) {
                  context.go(item['route'] as String);
                }
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: itemColor,
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['title'] as String,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.w500,
                      color: itemColor,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
=======
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.s16,
            0,
            AppSpacing.s16,
            AppSpacing.s12,
          ),
          height: 66,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.45)
                    : AppColors.gray900.withValues(alpha: 0.12),
                blurRadius: 24,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.85)
                      : Colors.white.withValues(alpha: 0.88),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.12)
                        : Colors.white.withValues(alpha: 0.8),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(navItems.length, (index) {
                    final isSelected = index == currentIndex;
                    final item = navItems[index];

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!isSelected) {
                            HapticFeedback.selectionClick();
                            context.go(item['route'] as String);
                          }
                        },
                        behavior: HitTestBehavior.opaque,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFF6B00).withValues(alpha: 0.14)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AnimatedScale(
                                scale: isSelected ? 1.15 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isSelected ? item['activeIcon'] as IconData : item['icon'] as IconData,
                                  size: 22,
                                  color: isSelected
                                      ? const Color(0xFFFF6B00)
                                      : (isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item['title'] as String,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 10,
                                  fontWeight: isSelected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFFFF6B00)
                                      : (isDark
                                          ? AppColors.gray400
                                          : AppColors.gray600),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
>>>>>>> origin/admin-ahmed
      ),
    );
  }
}
