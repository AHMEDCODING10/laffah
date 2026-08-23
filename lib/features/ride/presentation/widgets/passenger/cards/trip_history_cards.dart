import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/widgets/glass_box.dart';
import '../rating_and_support_dialog.dart';

/// Helper widget for subtle, calm divider that avoids harsh dark lines
Widget _buildSoftDivider(bool isDark) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(
      height: 1,
      thickness: 0.7,
      color: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.6),
    ),
  );
}

/// Shared helper widget for displaying connected route timeline (Pickup -> Dropoff)
Widget _buildRouteTimeline({
  required String pickup,
  required String dropoff,
  required bool isDark,
}) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Column(
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 2),
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.35),
                  blurRadius: 3,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
          Container(
            width: 1.5,
            height: 18,
            margin: const EdgeInsets.symmetric(vertical: 2),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.15)
                  : AppColors.gray300,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const Icon(
            Icons.location_on_rounded,
            color: AppColors.danger,
            size: 13,
          ),
        ],
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'نقطة الانطلاق: ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gray500,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    pickup.isNotEmpty ? pickup : 'موقعك الحالي',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Text(
                  'الوجهة: ',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.gray500,
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Expanded(
                  child: Text(
                    dropoff.isNotEmpty ? dropoff : 'غير محدد',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: isDark ? Colors.white : AppColors.gray900,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}

/// ActiveTripCard — Displays ongoing / active rides or parcel orders in the trip history screen.
class ActiveTripCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final VoidCallback onCancel;

  const ActiveTripCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final isRide = item['isRide'] ?? true;
    final price = (item['price'] ?? item['fare'] ?? item['final_price'] ?? 0) as num;

    return GlassBox(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: BorderRadius.circular(15),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: Type, Status, and Active Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isRide
                          ? AppColors.primary500.withValues(alpha: 0.1)
                          : AppColors.info.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRide
                          ? Icons.directions_car_filled_rounded
                          : Icons.inventory_2_rounded,
                      color: isRide ? AppColors.primary500 : AppColors.info,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['statusAr'] ?? 'قيد التنفيذ',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (price > 0)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Text(
                        '${price.toDouble().toStringAsFixed(0)} ريال',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary500.withValues(alpha: 0.25),
                        width: 0.8,
                      ),
                    ),
                    child: const Text(
                      'نشط الآن',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildSoftDivider(isDark),
          if (isRide)
            _buildRouteTimeline(
              pickup: item['pickup'] ?? '',
              dropoff: item['dropoff'] ?? '',
              isDark: isDark,
            )
          else ...[
            Text(
              item['orderNumber'] ?? '',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.primary500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'محتوى الطرد: ${item['parcelContent'] ?? ''}',
              style: TextStyle(
                fontSize: 11.5,
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
          _buildSoftDivider(isDark),
          // Cancel Button - Sleek & Compact
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(
                Icons.cancel_outlined,
                size: 14,
                color: AppColors.danger,
              ),
              label: const Text(
                'إلغاء الطلب',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.danger,
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.25),
                  width: 0.9,
                ),
                backgroundColor: AppColors.danger.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ScheduledTripCard — Displays scheduled trips in the trip history screen.
class ScheduledTripCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final VoidCallback onCancel;

  const ScheduledTripCard({
    super.key,
    required this.item,
    required this.isDark,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: BorderRadius.circular(15),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary500,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة مجدولة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['scheduledAt'] ?? 'مجدولة لاحقاً',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${((item['estimatedFare'] ?? item['fare'] ?? item['price'] ?? 0) as num).toDouble().toStringAsFixed(0)} ريال',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          _buildSoftDivider(isDark),
          _buildRouteTimeline(
            pickup: item['pickup'] ?? '',
            dropoff: item['dropoff'] ?? '',
            isDark: isDark,
          ),
          _buildSoftDivider(isDark),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(
                Icons.cancel_outlined,
                size: 14,
                color: AppColors.danger,
              ),
              label: const Text(
                'إلغاء المشوار المجدول',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: AppColors.danger,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.25),
                  width: 0.9,
                ),
                backgroundColor: AppColors.danger.withValues(alpha: 0.04),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// PastTripCard — Displays completed past trips in the trip history screen.
class PastTripCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const PastTripCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isRide = item['isRide'] ?? true;
    final fare = ((item['fare'] ?? item['price'] ?? 0) as num).toDouble();

    return GlassBox(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: BorderRadius.circular(15),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type & Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isRide
                          ? AppColors.primary500.withValues(alpha: 0.1)
                          : AppColors.info.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRide
                          ? Icons.directions_car_filled_rounded
                          : Icons.inventory_2_rounded,
                      color: isRide ? AppColors.primary500 : AppColors.info,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['date'] ?? 'مكتملة',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'مكتملة',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${fare.toStringAsFixed(0)} ريال',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.primary500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          _buildSoftDivider(isDark),
          _buildRouteTimeline(
            pickup: item['pickup'] ?? '',
            dropoff: item['dropoff'] ?? '',
            isDark: isDark,
          ),
          _buildSoftDivider(isDark),
          // Captain info & support button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 14,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'الكابتن: ${item['captainName'] ?? 'كابتن لَفَّة'}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.gray300 : AppColors.gray800,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => RatingAndSupportDialog(
                      tripId: item['id']?.toString() ?? '',
                      captainName: item['captainName'] ?? 'الكابتن',
                      fare: fare,
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 14,
                        color: AppColors.primary500,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'مساعدة والتقييم',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// CancelledTripCard — Displays cancelled trips in the trip history screen.
class CancelledTripCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;
  final VoidCallback? onDelete;

  const CancelledTripCard({
    super.key,
    required this.item,
    required this.isDark,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      margin: const EdgeInsets.only(bottom: 10),
      borderRadius: BorderRadius.circular(15),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      customBgColor: isDark ? const Color(0xFF161B26) : Colors.white,
      customBorderColor: isDark
          ? Colors.white.withValues(alpha: 0.07)
          : AppColors.gray200.withValues(alpha: 0.8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Calm, clean muted icon and soft badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : AppColors.gray100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_toggle_off_rounded,
                      color: isDark ? AppColors.gray400 : AppColors.gray500,
                      size: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['date'] ?? 'ملغية',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'ملغية',
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ],
          ),
          _buildSoftDivider(isDark),
          _buildRouteTimeline(
            pickup: item['pickup'] ?? '',
            dropoff: item['dropoff'] ?? '',
            isDark: isDark,
          ),
          _buildSoftDivider(isDark),
          // Bottom Row: Cancellation Reason on Right, Delete Button on Left
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: isDark
                          ? const Color(0xFFEF6C6C)
                          : const Color(0xFFD34545),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'سبب الإلغاء: ${item['reason'] ?? 'تم الإلغاء بواسطة الراكب'}',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFEF6C6C)
                              : const Color(0xFFD34545),
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onDelete,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.primary500,
                            size: 13,
                          ),
                          SizedBox(width: 3),
                          Text(
                            'حذف',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
