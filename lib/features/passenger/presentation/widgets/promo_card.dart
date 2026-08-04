import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../data/datasources/fake_passenger_core_repository.dart';

/// PromoCard — Item widget displaying promo code details with copy & apply callbacks.
class PromoCard extends StatelessWidget {
  final bool isDark;
  final PromoVoucherModel promo;
  final VoidCallback onApply;

  const PromoCard({
    super.key,
    required this.isDark,
    required this.promo,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBox(
      borderRadius: AppSpacing.radiusLG,
      margin: const EdgeInsets.only(bottom: AppSpacing.s14),
      padding: const EdgeInsets.all(AppSpacing.s16),
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
                      Icons.local_offer_rounded,
                      color: AppColors.primary500,
                      size: 18,
                    ),
                  ),
                  AppSpacing.w10,
                  Text(
                    promo.discountTitle,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.s10,
                  vertical: AppSpacing.s4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary500.withValues(alpha: 0.12),
                  borderRadius: AppSpacing.borderXS,
                ),
                child: Text(
                  promo.code,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.primary500,
                  ),
                ),
              ),
            ],
          ),
          AppSpacing.h10,
          Text(
            promo.description,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: isDark ? AppColors.gray400 : AppColors.gray600,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.s10),
            child: Divider(height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 14,
                    color: AppColors.gray500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    promo.expiryDate,
                    style: const TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: onApply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  foregroundColor: AppColors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s16,
                    vertical: AppSpacing.s6,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderSM,
                  ),
                ),
                child: const Text(
                  'استخدام الكود',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 11.5,
                    color: AppColors.white,
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
