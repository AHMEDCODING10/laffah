import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// ParcelHistoryPage — Shows all past and current parcel deliveries for the Passenger.
class ParcelHistoryPage extends StatelessWidget {
  const ParcelHistoryPage({super.key});

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
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'سجل الطرود والأمانات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
          },
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.s24),
          children: [
            Text(
              'الطرود الحالية',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,
            _buildParcelItem(
              trackingId: 'LF-9321',
              destination: 'حدة، مركز الكميم',
              time: 'اليوم، 10:00 صباحاً',
              status: 'قيد التوصيل',
              isDark: isDark,
            ),
            AppSpacing.h32,
            Text(
              'الطرود السابقة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,
            _buildParcelItem(
              trackingId: 'LF-8842',
              destination: 'جامعة صنعاء',
              time: '15 يوليو 2026',
              status: 'تم التسليم',
              isDark: isDark,
            ),
            _buildParcelItem(
              trackingId: 'LF-7210',
              destination: 'شارع الستين، بالقرب من جولة عصر',
              time: '10 يوليو 2026',
              status: 'ملغي',
              isDark: isDark,
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildParcelItem({
    required String trackingId,
    required String destination,
    required String time,
    required String status,
    required bool isDark,
  }) {
    final bool isActive = status == 'قيد التوصيل';
    final bool isCanceled = status == 'ملغي';
    final Color statusColor = isCanceled
        ? AppColors.danger
        : (isActive ? const Color(0xFF3B82F6) : const Color(0xFF22C55E));

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark
              ? AppColors.white.withValues(alpha: 0.05)
              : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child:
                Icon(Icons.inventory_2_rounded, color: statusColor, size: 24),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معرف الطرد: $trackingId',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.gray400 : AppColors.gray500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppSpacing.h8,
                Text(
                  destination,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
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
