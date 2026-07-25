import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

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

    const List<_CaptainNavItem> items = [
      _CaptainNavItem(
        icon: Icons.navigation_rounded,
        activeIcon: Icons.navigation_rounded,
        label: 'الرئيسية',
      ),
      _CaptainNavItem(
        icon: Icons.receipt_long_rounded,
        activeIcon: Icons.receipt_long_rounded,
        label: 'الرحلات',
      ),
      _CaptainNavItem(
        icon: Icons.account_balance_wallet_rounded,
        activeIcon: Icons.account_balance_wallet_rounded,
        label: 'الأرباح',
      ),
      _CaptainNavItem(
        icon: Icons.notifications_rounded,
        activeIcon: Icons.notifications_rounded,
        label: 'التنبيهات',
      ),
      _CaptainNavItem(
        icon: Icons.person_rounded,
        activeIcon: Icons.person_rounded,
        label: 'الحساب',
      ),
    ];

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
                  children: List.generate(items.length, (index) {
                    final isSelected = index == currentIndex;
                    final item = items[index];

                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          onTap(index);
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
                                  isSelected ? item.activeIcon : item.icon,
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
                                item.label,
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
      ),
    );
  }
}

class _CaptainNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _CaptainNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
