import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// CaptainOrderDetailsDialog — Detailed preview modal sheet for ride & parcel requests,
/// including support for Multi-Stop trips (مشوار متعدد المحطات) and Yemeni Rial pricing breakdown.
class CaptainOrderDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onAccept;

  const CaptainOrderDetailsDialog({
    super.key,
    required this.order,
    required this.onAccept,
  });

  static void show({
    required BuildContext context,
    required Map<String, dynamic> order,
    required VoidCallback onAccept,
  }) {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaptainOrderDetailsDialog(
        order: order,
        onAccept: onAccept,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final List<String> stops = (order['stops'] as List<dynamic>?)?.cast<String>() ?? [];
    final bool isMultiStop = stops.isNotEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.2),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF141822).withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                border: Border.all(
                  color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                  width: 1.2,
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Drag Handle Bar
                    Center(
                      child: Container(
                        width: 44,
                        height: 4.5,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white24 : Colors.black12,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    AppSpacing.h16,

                    // Header Badge & Fare
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFF6B00).withValues(alpha: 0.15),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  order['isParcel'] == true ? Icons.inventory_2_rounded : Icons.two_wheeler_rounded,
                                  color: const Color(0xFFFF6B00),
                                  size: 20,
                                ),
                              ),
                              AppSpacing.w10,
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order['title'] ?? 'تفاصيل الطلب',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontFamily: 'IBM Plex Sans Arabic',
                                        fontWeight: FontWeight.w900,
                                        fontSize: 14.5,
                                        color: isDark ? Colors.white : AppColors.gray900,
                                      ),
                                    ),
                                    if (isMultiStop)
                                      const Text(
                                        '⚡ مشوار متعدد المحطات والتوقفات',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontFamily: 'IBM Plex Sans Arabic',
                                          fontSize: 10.5,
                                          color: Color(0xFFFF6B00),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 8),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6B00).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFFF6B00).withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            order['price'] ?? '0 ر.ي',
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h16,

                    // Passenger Info Card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFFFF6B00).withValues(alpha: 0.18),
                            child: Text(
                              (order['passengerName'] as String?)?.isNotEmpty == true ? order['passengerName'][0] : 'م',
                              style: const TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFFF6B00),
                              ),
                            ),
                          ),
                          AppSpacing.w12,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['passengerName'] ?? 'العميل',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: isDark ? Colors.white : AppColors.gray900,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  order['description'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 11,
                                    color: AppColors.gray500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h16,

                    // Route Card (Pickup, Multi-Stops if any, and Final Dropoff)
                    const Text(
                      'مسار المشوار المحسوب:',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gray500,
                      ),
                    ),
                    AppSpacing.h8,

                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.03) : AppColors.gray50,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Pickup
                          _buildRoutePoint(
                            color: Colors.green,
                            label: 'نقطة الانطلاق (A)',
                            address: order['pickup'] ?? 'الاستلام',
                            isDark: isDark,
                          ),

                          // Multi-stops if present
                          if (isMultiStop)
                            ...stops.asMap().entries.map((entry) {
                              return Column(
                                children: [
                                  _buildConnector(isDark),
                                  _buildRoutePoint(
                                    color: Colors.amber,
                                    label: 'محطة توقف (${entry.key + 1})',
                                    address: entry.value,
                                    isDark: isDark,
                                  ),
                                ],
                              );
                            }),

                          _buildConnector(isDark),

                          // Dropoff
                          _buildRoutePoint(
                            color: Colors.redAccent,
                            label: 'الوجهة النهائية (B)',
                            address: order['dropoff'] ?? 'الوصول',
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.h16,

                    // Specs Row (Distance, Time)
                    Row(
                      children: [
                        Expanded(
                          child: _buildSpecCard(
                            isDark,
                            Icons.map_rounded,
                            'إجمالي المسافة',
                            order['distance'] ?? '2.5 كم',
                          ),
                        ),
                        AppSpacing.w12,
                        Expanded(
                          child: _buildSpecCard(
                            isDark,
                            Icons.schedule_rounded,
                            'الوقت المقدر',
                            order['eta'] ?? '8 دقائق',
                          ),
                        ),
                      ],
                    ),

                    AppSpacing.h24,

                    // Accept Button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onAccept();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF6B00),
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: const Color(0xFFFF6B00).withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        ),
                        icon: const Icon(Icons.flash_on_rounded, size: 20),
                        label: const Text(
                          'قبول الطلب والبدء الآن ⚡',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),

                    AppSpacing.h16,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoutePoint({
    required Color color,
    required String label,
    required String address,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 4),
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        AppSpacing.w12,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                address,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(right: 5),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 2,
          height: 16,
          color: isDark ? Colors.white24 : Colors.black12,
        ),
      ),
    );
  }

  Widget _buildSpecCard(bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : AppColors.gray100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: const Color(0xFFFF6B00)),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 9.5,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                  color: isDark ? Colors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
