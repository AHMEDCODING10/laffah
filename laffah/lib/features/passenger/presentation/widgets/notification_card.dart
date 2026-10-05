import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../data/models/notification_item_model.dart';

/// NotificationCard — Item widget displaying notification details with unread indicator and category icon.
class NotificationCard extends StatelessWidget {
  final bool isDark;
  final NotificationItemModel item;
  final VoidCallback? onTap;

  const NotificationCard({
    super.key,
    required this.isDark,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = item.type == 'trip_cancelled' ||
        item.title.contains('إلغاء') ||
        item.message.contains('إلغاء') ||
        item.message.contains('ملغي');

    final cardColor = item.isUnread
        ? (isDark
            ? (isCancelled
                ? AppColors.danger.withValues(alpha: 0.08)
                : const Color(0xFF1E2330))
            : (isCancelled
                ? AppColors.danger.withValues(alpha: 0.04)
                : AppColors.primary500.withValues(alpha: 0.04)))
        : (isDark ? const Color(0xFF161B26) : Colors.white);

    final borderColor = isCancelled
        ? AppColors.danger.withValues(alpha: 0.35)
        : (item.isUnread
            ? AppColors.primary500.withValues(alpha: 0.4)
            : (isDark
                ? Colors.white.withValues(alpha: 0.07)
                : AppColors.gray200.withValues(alpha: 0.8)));

    final iconColor = isCancelled ? AppColors.danger : _getCategoryColor(item.category);
    final iconData = isCancelled ? Icons.cancel_rounded : _getCategoryIcon(item.category);
    final badgeColor = isCancelled ? AppColors.danger : AppColors.primary500;

    return GlassBox(
      borderRadius: BorderRadius.circular(16),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBgColor: cardColor,
      customBorderColor: borderColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon with Unread Badge
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 18,
                  ),
                ),
                if (item.isUnread)
                  Positioned(
                    top: -1,
                    right: -1,
                    child: Container(
                      width: 9,
                      height: 9,
                      decoration: BoxDecoration(
                        color: badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF161B26) : Colors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: item.isUnread
                                ? FontWeight.w900
                                : FontWeight.bold,
                            fontSize: 13.5,
                            color: isCancelled
                                ? AppColors.danger
                                : (isDark ? Colors.white : AppColors.gray900),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11.5,
                      height: 1.35,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  if (item.captainName != null) ...[
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isCancelled ? AppColors.danger : AppColors.primary500).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isCancelled ? Icons.cancel_outlined : Icons.person_pin_circle_rounded,
                            size: 13,
                            color: isCancelled ? AppColors.danger : AppColors.primary500,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            item.captainName!,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.bold,
                              fontSize: 10.5,
                              color: isCancelled ? AppColors.danger : AppColors.primary500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'rides':
        return Icons.directions_car_rounded;
      case 'parcels':
        return Icons.inventory_2_rounded;
      case 'offers':
        return Icons.local_offer_rounded;
      case 'messages':
        return Icons.chat_bubble_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'rides':
        return AppColors.primary500;
      case 'parcels':
        return Colors.orange;
      case 'offers':
        return AppColors.success;
      case 'messages':
        return Colors.blue;
      default:
        return AppColors.primary500;
    }
  }
}
