import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

/// HomeBottomNavBar — Persistent bottom navigation bar for the 4 passenger shell tabs:
/// (0: الرئيسية, 1: رحلاتي, 2: المحفظة, 3: الحساب).
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
        'route': LaffahRoutes.passengerHome,
      },
      {
        'title': 'رحلاتي',
        'icon': Icons.receipt_long_rounded,
        'route': LaffahRoutes.passengerHistory,
      },
      {
        'title': 'المحفظة',
        'icon': Icons.account_balance_wallet_rounded,
        'route': LaffahRoutes.passengerWallet,
      },
      {
        'title': 'الحساب',
        'icon': Icons.person_rounded,
        'route': LaffahRoutes.passengerProfile,
      },
    ];

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
      ),
    );
  }
}
