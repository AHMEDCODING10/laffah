import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// NotificationsPage — Central hub for passenger notifications.
/// Includes trip updates, promo codes, and system alerts.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'الإشعارات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.done_all_rounded, color: isDark ? AppColors.gray400 : AppColors.gray600, size: 20),
              onPressed: () {},
              tooltip: 'تحديد الكل كمقروء',
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s8),
          children: [
            _buildNotificationItem(
              title: 'خصم 20% على رحلتك القادمة!',
              message: 'استخدم الكود LAFFAH20 واستمتع بخصم على رحلتك بالدراجة النارية.',
              time: 'منذ ساعتين',
              icon: Icons.local_offer_rounded,
              color: const Color(0xFF3B82F6),
              isUnread: true,
              isDark: isDark,
            ),
            _buildNotificationItem(
              title: 'تم شحن رصيدك بنجاح',
              message: 'تمت إضافة 5,000 ريال إلى محفظتك عبر الكريمي.',
              time: 'أمس، 04:15 عصراً',
              icon: Icons.account_balance_wallet_rounded,
              color: const Color(0xFF10B981),
              isUnread: false,
              isDark: isDark,
            ),
            _buildNotificationItem(
              title: 'رحلتك اكتملت بنجاح',
              message: 'نأمل أن تكون قد استمتعت برحلتك مع الكابتن محمد علي.',
              time: '18 يوليو 2026',
              icon: Icons.motorcycle_rounded,
              color: const Color(0xFFFF6B00),
              isUnread: false,
              isDark: isDark,
            ),
            _buildNotificationItem(
              title: 'طردك في الطريق',
              message: 'الكابتن استلم الطرد وهو الآن متوجه نحو موقع التسليم.',
              time: '15 يوليو 2026',
              icon: Icons.inventory_2_rounded,
              color: const Color(0xFFFF6B00),
              isUnread: false,
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationItem({
    required String title,
    required String message,
    required String time,
    required IconData icon,
    required Color color,
    required bool isUnread,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isUnread 
            ? (isDark ? color.withValues(alpha: 0.1) : color.withValues(alpha: 0.05))
            : (isDark ? AppColors.surfaceDark : AppColors.white),
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isUnread 
              ? color.withValues(alpha: 0.3) 
              : (isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 15,
                          fontWeight: isUnread ? FontWeight.w900 : FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.gray900,
                        ),
                      ),
                    ),
                    if (isUnread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B00),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  message,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                    height: 1.4,
                  ),
                ),
                AppSpacing.h12,
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 11,
                    color: isDark ? AppColors.gray500 : AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

