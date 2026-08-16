import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';

/// CaptainRideInvoicePage — Shown to the captain immediately after a ride completes.
/// Displays the cash amount to collect from the passenger.
class CaptainRideInvoicePage extends StatelessWidget {
  const CaptainRideInvoicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded,
                color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => context.go(LaffahRoutes.captainHome),
          ),
          centerTitle: true,
          title: Text(
            'فاتورة الرحلة',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF22C55E),
                  size: 40,
                ),
              ),
              AppSpacing.h16,

              Text(
                'الرحلة اكتملت بنجاح!',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),

              AppSpacing.h8,
              const Text(
                'الرجاء تحصيل المبلغ التالي من الراكب',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  color: AppColors.gray500,
                ),
              ),

              AppSpacing.h32,

              // Collection Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(
                    color: const Color(0xFFFF6B00).withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '1,250',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFF6B00),
                            height: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 6),
                          child: Text(
                            'ريال يمني',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFFF6B00),
                            ),
                          ),
                        ),
                      ],
                    ),
                    AppSpacing.h16,
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B00).withValues(alpha: 0.1),
                        borderRadius: AppSpacing.radiusMD,
                      ),
                      child: const Text(
                        'دفع نقدي',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B00),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.h32,

              Container(
                padding: const EdgeInsets.all(AppSpacing.s16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.white.withValues(alpha: 0.02)
                      : AppColors.gray50,
                  borderRadius: AppSpacing.radiusMD,
                ),
                child: Column(
                  children: [
                    _buildInvoiceRow('أجرة الرحلة', '1,250 ريال', isDark),
                    AppSpacing.h12,
                    _buildInvoiceRow(
                        'رسوم لَفَّة (مستقطعة)', '- 125 ريال', isDark,
                        isNegative: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.gray300),
                    ),
                    _buildInvoiceRow('صافي الربح', '1,125 ريال', isDark,
                        isBold: true, color: const Color(0xFF22C55E)),
                  ],
                ),
              ),

              AppSpacing.h40,

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(LaffahRoutes.captainHome);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusMD,
                    ),
                  ),
                  child: const Text(
                    'تم استلام المبلغ',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, bool isDark,
      {bool isBold = false, bool isNegative = false, Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 14,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: isBold ? 'monospace' : 'IBM Plex Sans Arabic',
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: color ??
                (isNegative
                    ? AppColors.danger
                    : (isDark ? AppColors.white : AppColors.gray900)),
          ),
        ),
      ],
    );
  }
}
