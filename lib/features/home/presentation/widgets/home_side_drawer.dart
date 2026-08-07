import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
<<<<<<< HEAD
=======
import 'package:url_launcher/url_launcher.dart';
>>>>>>> origin/admin-ahmed
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';

/// HomeSideDrawer — Passenger navigation side drawer with profile header,
/// navigation links, support & complaints, and role switching.
class HomeSideDrawer extends StatelessWidget {
  final bool isDark;

  const HomeSideDrawer({
    super.key,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                'الراكب - لَفّة',
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

            // Drawer Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.home_rounded,
                    title: 'الرئيسية',
                    route: LaffahRoutes.passengerHome,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.receipt_long_rounded,
                    title: 'رحلاتي وحجوزاتي',
                    route: LaffahRoutes.passengerHistory,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.account_balance_wallet_rounded,
                    title: 'محفظة لَفّة',
                    route: LaffahRoutes.passengerWallet,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.bookmark_rounded,
                    title: 'العناوين المحفوظة',
                    route: LaffahRoutes.passengerSavedPlaces,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.local_offer_rounded,
                    title: 'أكواد الخصم والعروض',
                    route: LaffahRoutes.passengerPromoCode,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    route: LaffahRoutes.passengerNotifications,
                  ),
                  const Divider(),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.support_agent_rounded,
                    title: 'الدعم الفني والشكاوى',
<<<<<<< HEAD
                    route: LaffahRoutes.passengerSupportTickets,
=======
                    onTap: () async {
                      Navigator.pop(context); // Close drawer
                      final Uri url = Uri.parse('whatsapp://send?phone=+967770291452');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        final Uri phoneUrl = Uri.parse('tel:+967770291452');
                        if (await canLaunchUrl(phoneUrl)) {
                          await launchUrl(phoneUrl);
                        }
                      }
                    },
>>>>>>> origin/admin-ahmed
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.person_outline_rounded,
                    title: 'الملف الشخصي',
                    route: LaffahRoutes.passengerProfile,
                  ),
                  _buildDrawerTile(
                    context: context,
                    icon: Icons.published_with_changes_rounded,
                    title: 'التبديل إلى وضع الكابتن',
<<<<<<< HEAD
                    route: LaffahRoutes.roleSelection,
=======
                    onTap: () {
                      Navigator.pop(context);
                      // context.go(LaffahRoutes.roleSelection); // TODO: Implement role selection
                    },
>>>>>>> origin/admin-ahmed
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
<<<<<<< HEAD
    required String route,
=======
    String? route,
    VoidCallback? onTap,
>>>>>>> origin/admin-ahmed
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
<<<<<<< HEAD
      onTap: () {
        Navigator.pop(context); // Close drawer
        context.go(route);
=======
      onTap: onTap ?? () {
        Navigator.pop(context); // Close drawer
        if (route != null) {
          context.go(route);
        }
>>>>>>> origin/admin-ahmed
      },
    );
  }
}
