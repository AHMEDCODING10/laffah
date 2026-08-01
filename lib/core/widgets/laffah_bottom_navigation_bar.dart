import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// LaffahBottomNavigationBar — Persistent floating capsule bottom navigation bar for Laffah passenger shell.
/// Features 4 primary tabs: الرئيسية, رحلاتي, المحفظة, الحساب.
class LaffahBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LaffahBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final List<Map<String, dynamic>> navItems = [
      {
        'title': 'الرئيسية',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home_rounded,
      },
      {
        'title': 'رحلاتي',
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long_rounded,
      },
      {
        'title': 'المحفظة',
        'icon': Icons.account_balance_wallet_outlined,
        'activeIcon': Icons.account_balance_wallet_rounded,
      },
      {
        'title': 'الحساب',
        'icon': Icons.person_outline_rounded,
        'activeIcon': Icons.person_rounded,
      },
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        bottom: true,
        maintainBottomViewPadding: true,
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          height: 66,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.white,
            borderRadius: BorderRadius.circular(36),
            border: Border.all(
              color: isDark
                  ? AppColors.white.withValues(alpha: 0.12)
                  : AppColors.gray200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.10),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: AppColors.primary500.withValues(alpha: 0.06),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
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
                  : (isDark ? AppColors.gray400 : AppColors.gray600);

              return Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => onTap(index),
                    borderRadius: BorderRadius.circular(36),
                    splashColor: AppColors.primary500.withValues(alpha: 0.1),
                    highlightColor: AppColors.primary500.withValues(alpha: 0.05),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? AppColors.primary500.withValues(alpha: 0.12)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              (isActive ? item['activeIcon'] : item['icon'])
                                  as IconData,
                              color: itemColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['title'] as String,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight:
                                  isActive ? FontWeight.w800 : FontWeight.w500,
                              color: itemColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

