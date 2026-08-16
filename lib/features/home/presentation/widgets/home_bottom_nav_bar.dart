import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';

/// HomeBottomNavBar — Ultra-modern, floating glassmorphic navigation dock
/// designed specifically for Laffah Passenger screens, matching the Captain UI 100%.
/// Features iOS-inspired glassmorphism, animated active indicator pills,
/// haptic feedback, and responsive RTL layout.
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
        'title': AppLocalizations.of(context)!.pass_nav_home,
        'icon': Icons.home_rounded,
        'route': LaffahRoutes.passengerHome,
      },
      {
        'title': AppLocalizations.of(context)!.pass_nav_trips,
        'icon': Icons.receipt_long_rounded,
        'route': LaffahRoutes.passengerHistory,
      },
      {
        'title': AppLocalizations.of(context)!.pass_nav_wallet,
        'icon': Icons.account_balance_wallet_rounded,
        'route': LaffahRoutes.passengerWallet,
      },
      {
        'title': AppLocalizations.of(context)!.pass_nav_account,
        'icon': Icons.person_rounded,
        'route': LaffahRoutes.passengerProfile,
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        top: false,
        child: Container(
          margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.5)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141822).withValues(alpha: 0.9)
                      : Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : Colors.black.withValues(alpha: 0.05),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(navItems.length, (index) {
                    final isSelected = index == currentIndex;
                    final item = navItems[index];

                    return GestureDetector(
                      onTap: () {
                        if (!isSelected) {
                          HapticFeedback.selectionClick();
                          context.go(item['route'] as String);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 350),
                        curve: Curves.easeOutCirc,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSelected ? 16 : 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFF6B00).withValues(alpha: 0.15)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              item['icon'] as IconData,
                              size: 24,
                              color: isSelected
                                  ? const Color(0xFFFF6B00)
                                  : (isDark
                                      ? AppColors.gray500
                                      : AppColors.gray400),
                            ),
                            if (isSelected) ...[
                              const SizedBox(width: 8),
                              Text(
                                item['title'] as String,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF6B00),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
