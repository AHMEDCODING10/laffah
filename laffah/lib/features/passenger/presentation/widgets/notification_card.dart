import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
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
    final cardColor = item.isUnread
        ? (isDark
            ? AppColors.primary500.withValues(alpha: 0.08)
            : AppColors.primary500.withValues(alpha: 0.05))
        : null;

    return GlassBox(
      borderRadius: AppSpacing.radiusLG,
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      customBgColor: cardColor,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Icon or Avatar
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s10),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(item.category)
                        .withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getCategoryIcon(item.category),
                    color: _getCategoryColor(item.category),
                    size: 20,
                  ),
                ),
                if (item.isUnread)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              isDark ? AppColors.surfaceDark : AppColors.white,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            AppSpacing.w12,
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
                            fontSize: 14,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item.time,
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 10.5,
                          color: AppColors.gray500,
                        ),
                      ),
                    ],
                  ),
                  AppSpacing.h4,
                  Text(
                    item.message,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      height: 1.4,
                      color: isDark ? AppColors.gray400 : AppColors.gray600,
                    ),
                  ),
                  if (item.captainName != null) ...[
                    AppSpacing.h6,
                    Row(
                      children: [
                        const Icon(
                          Icons.person_pin_circle_rounded,
                          size: 14,
                          color: AppColors.primary500,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          item.captainName!,
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
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
