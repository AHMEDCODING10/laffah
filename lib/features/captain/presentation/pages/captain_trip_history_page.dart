import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

import '../../../../core/router/app_router.dart';

/// CaptainTripHistoryPage — Dedicated history page for Captains showing completed trips,
/// earnings per trip, and canceled rides.
class CaptainTripHistoryPage extends StatelessWidget {
  const CaptainTripHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppColors.white : AppColors.gray900, size: 20),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(LaffahRoutes.captainHome);
              }
            },
          ),
          title: Text(
            'سجل الرحلات',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          children: [
            _buildStatSummary(isDark),
            AppSpacing.h32,
            Text(
              'رحلات اليوم',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,
            _buildTripItem(
              type: 'ride',
              destination: 'جامعة صنعاء الجديدة',
              time: '10:30 صباحاً',
              earnings: '1,200',
              status: 'مكتملة',
              isDark: isDark,
            ),
            _buildTripItem(
              type: 'parcel',
              destination: 'حدة، مركز الكميم',
              time: '09:15 صباحاً',
              earnings: '1,500',
              status: 'مكتملة',
              isDark: isDark,
            ),
            _buildTripItem(
              type: 'ride',
              destination: 'شارع الستين الجنوبي',
              time: '08:00 صباحاً',
              earnings: '0',
              status: 'ملغية',
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatSummary(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s20),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B00).withOpacity(0.1),
        borderRadius: AppSpacing.radiusLG,
        border: Border.all(
          color: const Color(0xFFFF6B00).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(title: 'الرحلات', value: '12', isDark: isDark),
          Container(width: 1, height: 40, color: const Color(0xFFFF6B00).withOpacity(0.3)),
          _StatItem(title: 'الطرود', value: '4', isDark: isDark),
          Container(width: 1, height: 40, color: const Color(0xFFFF6B00).withOpacity(0.3)),
          _StatItem(title: 'الأرباح', value: '14K', isDark: isDark),
        ],
      ),
    );
  }

  Widget _buildTripItem({
    required String type,
    required String destination,
    required String time,
    required String earnings,
    required String status,
    required bool isDark,
  }) {
    final bool isCanceled = status == 'ملغية';
    final IconData icon = type == 'ride' ? Icons.motorcycle_rounded : Icons.inventory_2_rounded;
    final Color iconColor = type == 'ride' ? const Color(0xFFFF6B00) : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s16),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isCanceled ? AppColors.gray500.withOpacity(0.1) : iconColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isCanceled ? AppColors.gray500 : iconColor, size: 24),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  destination,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.white : AppColors.gray900,
                    decoration: isCanceled ? TextDecoration.lineThrough : null,
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isCanceled ? '0 ريال' : '$earnings ريال',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isCanceled ? AppColors.gray500 : const Color(0xFF22C55E),
                ),
              ),
              AppSpacing.h4,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isCanceled 
                      ? AppColors.danger.withOpacity(0.1)
                      : const Color(0xFF22C55E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCanceled ? AppColors.danger : const Color(0xFF22C55E),
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

class _StatItem extends StatelessWidget {
  final String title;
  final String value;
  final bool isDark;

  const _StatItem({required this.title, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 24,
            fontWeight: FontWeight.w900,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 12,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
      ],
    );
  }
}

