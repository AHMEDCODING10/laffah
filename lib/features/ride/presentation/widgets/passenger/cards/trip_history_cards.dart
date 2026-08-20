import 'package:flutter/material.dart';
import '../../../../../../core/theme/app_colors.dart';
import '../../../../../../core/theme/app_spacing.dart';
import '../../../../../../core/widgets/glass_box.dart';
import '../rating_and_support_dialog.dart';

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

    return GlassBox(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: isRide
                          ? AppColors.primary500.withValues(alpha: 0.12)
                          : AppColors.info.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isRide
                          ? Icons.directions_car_filled_rounded
                          : Icons.inventory_2_rounded,
                      color: isRide ? AppColors.primary500 : AppColors.info,
                      size: 18,
                    ),
                  ),
                  AppSpacing.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['statusAr'],
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary500,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderXS,
                ),
                child: const Text(
                  'نشط الآن',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary500,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          if (isRide) ...[
            _buildRouteRow(
              Icons.radio_button_checked_rounded,
              AppColors.success,
              'نقطة الانطلاق',
              item['pickup'],
            ),
            AppSpacing.h12,
            _buildRouteRow(
              Icons.place_rounded,
              AppColors.danger,
              'الوجهة',
              item['dropoff'],
            ),
          ] else ...[
            Text(
              item['orderNumber'] ?? '',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                fontFamily: 'monospace',
                color: AppColors.primary500,
              ),
            ),
            AppSpacing.h6,
            Text(
              'محتوى الطرد: ${item['parcelContent'] ?? ''}',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'IBM Plex Sans Arabic',
                color: isDark ? AppColors.gray400 : AppColors.gray600,
              ),
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.danger.withValues(alpha: 0.12),
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderMD,
                    ),
                  ),
                  child: const Text(
                    'إلغاء الطلب',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'IBM Plex Sans Arabic',
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(
    IconData icon,
    Color iconColor,
    String label,
    String? address,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        AppSpacing.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                address ?? 'غير محدد',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: AppColors.primary500.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.primary500,
                      size: 18,
                    ),
                  ),
                  AppSpacing.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة مجدولة',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        _formatDate(item['time'] ?? item['scheduledAt']),
                        style: const TextStyle(
                          fontSize: 11,
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
                '${((item['estimatedFare'] ?? item['fare'] ?? item['price'] ?? 0) as num).toDouble().toStringAsFixed(0)} ريال مقدراً',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          _buildRouteRow(
            Icons.radio_button_checked_rounded,
            AppColors.success,
            'نقطة الانطلاق',
            item['pickup'],
          ),
          AppSpacing.h12,
          _buildRouteRow(
            Icons.place_rounded,
            AppColors.danger,
            'الوجهة',
            item['dropoff'],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onCancel,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderMD,
                    ),
                  ),
                  child: const Text(
                    'إلغاء المشوار المجدول',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(
    IconData icon,
    Color iconColor,
    String label,
    String? address,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        AppSpacing.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                address ?? 'غير محدد',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
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

    return GlassBox(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Type, Fare
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
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
                      size: 18,
                    ),
                  ),
                  AppSpacing.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['date'] ?? 'اليوم',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '${((item['fare'] ?? item['price'] ?? 0) as num).toDouble().toStringAsFixed(0)} ريال',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: AppColors.primary500,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          _buildRouteRow(
            Icons.radio_button_checked_rounded,
            AppColors.success,
            'نقطة الانطلاق',
            item['pickup'],
          ),
          AppSpacing.h12,
          _buildRouteRow(
            Icons.place_rounded,
            AppColors.danger,
            'الوجهة',
            item['dropoff'],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          // Captain info & support button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: AppColors.gray500,
                  ),
                  AppSpacing.w6,
                  Text(
                    'الكابتن: ${item['captainName']}',
                    style: TextStyle(
                      fontSize: 12,
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
                      fare: ((item['fare'] ?? item['price'] ?? 0) as num).toDouble(),
                    ),
                  );
                },
                borderRadius: AppSpacing.borderXS,
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 16,
                        color: AppColors.primary500,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'مساعدة والتقييم',
                        style: TextStyle(
                          fontSize: 11,
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

  Widget _buildRouteRow(
    IconData icon,
    Color iconColor,
    String label,
    String? address,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        AppSpacing.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                address ?? 'غير محدد',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// CancelledTripCard — Displays cancelled trips in the trip history screen.
class CancelledTripCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isDark;

  const CancelledTripCard({
    super.key,
    required this.item,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s8),
                    decoration: BoxDecoration(
                      color: AppColors.danger.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cancel_outlined,
                      color: AppColors.danger,
                      size: 18,
                    ),
                  ),
                  AppSpacing.w12,
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['type'] ?? 'رحلة',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                      Text(
                        item['date'] ?? 'اليوم',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.gray400 : AppColors.gray600,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s8,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.1),
                  borderRadius: AppSpacing.borderXS,
                ),
                child: const Text(
                  'ملغية',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.danger,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          _buildRouteRow(
            Icons.radio_button_checked_rounded,
            AppColors.success,
            'نقطة الانطلاق',
            item['pickup'],
          ),
          AppSpacing.h12,
          _buildRouteRow(
            Icons.place_rounded,
            AppColors.danger,
            'الوجهة',
            item['dropoff'],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 14,
                color: AppColors.danger,
              ),
              AppSpacing.w6,
              Expanded(
                child: Text(
                  'سبب الإلغاء: ${item['reason'] ?? 'تم الإلغاء بواسطة الراكب'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.danger,
                    fontFamily: 'IBM Plex Sans Arabic',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRouteRow(
    IconData icon,
    Color iconColor,
    String label,
    String? address,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 16),
        AppSpacing.w10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.gray500,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                address ?? 'غير محدد',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatDate(dynamic rawDate) {
  if (rawDate == null) return 'غداً، 08:00 ص';
  final dateStr = rawDate.toString();
  try {
    final dt = DateTime.parse(dateStr).toLocal();
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final amPm = dt.hour >= 12 ? 'م' : 'ص';
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} $hour12:${dt.minute.toString().padLeft(2, '0')} $amPm';
  } catch (_) {
    return dateStr;
  }
}
