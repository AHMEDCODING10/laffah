import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../router/app_router.dart';
import '../theme/app_colors.dart';

/// LaffahSideDrawer — Reusable side navigation drawer across Laffah passenger application.
class LaffahSideDrawer extends StatelessWidget {
  const LaffahSideDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // Drawer Header with User Profile
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
              ),
              currentAccountPicture: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const CircleAvatar(
                  backgroundColor: AppColors.white,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary500,
                    size: 36,
                  ),
                ),
              ),
              accountName: const Text(
                'الراكب - لَفَّة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.white,
                ),
              ),
              accountEmail: const Text(
                '+967 777 000 000',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 13,
                  color: AppColors.white,
                ),
              ),
            ),

            // Drawer Navigation Options List
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'الرئيسية',
                    route: LaffahRoutes.passengerHome,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    title: 'رحلاتي وحجوزاتي',
                    route: LaffahRoutes.passengerHistory,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'محفظة لَفَّة',
                    route: LaffahRoutes.passengerWallet,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.bookmark_rounded,
                    title: 'العناوين المحفوظة',
                    route: LaffahRoutes.passengerSavedPlaces,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.local_offer_rounded,
                    title: 'أكواد الخصم والعروض',
                    route: LaffahRoutes.passengerPromoCode,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    route: LaffahRoutes.passengerNotifications,
                    isDark: isDark,
                  ),
                  const Divider(),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني والشكاوى',
                    route: LaffahRoutes.passengerSupportTickets,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'الملف الشخصي',
                    route: LaffahRoutes.passengerProfile,
                    isDark: isDark,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.published_with_changes_rounded,
                    title: 'التبديل إلى وضع الكابتن',
                    route: LaffahRoutes.roleSelection,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String route,
    required bool isDark,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary500, size: 22),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'IBM Plex Sans Arabic',
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.white : AppColors.gray900,
        ),
      ),
      onTap: () {
        Navigator.pop(context); // Close side drawer
        context.go(route);
      },
    );
  }
}
