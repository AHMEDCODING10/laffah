import '../../../../../l10n/app_localizations.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';

/// CaptainFloatingBottomBar — Ultra-modern, floating glassmorphic navigation dock
/// designed specifically for Laffah Captain screens.
/// Features iOS-inspired glassmorphism, animated active indicator pills,
/// haptic feedback, and responsive RTL layout.
class CaptainFloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CaptainFloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<_CaptainNavItem> items = [
      _CaptainNavItem(
          icon: Icons.navigation_rounded,
          label: AppLocalizations.of(context)!.capt_nav_home),
      _CaptainNavItem(icon: Icons.receipt_long_rounded, label: AppLocalizations.of(context)!.capt_nav_trips),
      _CaptainNavItem(
          icon: Icons.account_balance_wallet_rounded, label: AppLocalizations.of(context)!.capt_nav_earnings),
      _CaptainNavItem(
          icon: Icons.notifications_rounded,
          label: AppLocalizations.of(context)!.capt_nav_alerts),
      _CaptainNavItem(
          icon: Icons.person_rounded,
          label: AppLocalizations.of(context)!.capt_nav_account),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                  children: List.generate(items.length, (index) {
                    final isSelected = index == currentIndex;
                    final item = items[index];

                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
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
                              item.icon,
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
                                item.label,
                                style: const TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFFFF6B00),
                                ),
                              ),
                            ]
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

class _CaptainNavItem {
  final IconData icon;
  final String label;

  const _CaptainNavItem({
    required this.icon,
    required this.label,
  });
}
