import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';

/// RideInvoicePage — Displayed immediately after a ride concludes.
/// Shows the final fare in YER, distance, and time, specifically designed
/// for the Yemeni cash-dominant market.
class RideInvoicePage extends StatelessWidget {
  const RideInvoicePage({super.key});

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
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => context.go(LaffahRoutes.passengerHome),
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
              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.1),
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
              
              AppSpacing.h32,

              // Invoice Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(
                    color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'المبلغ المطلوب دفعه',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    AppSpacing.h8,
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
                            'ريال',
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
                    AppSpacing.h24,
                    
                    const Divider(color: AppColors.gray300),
                    
                    AppSpacing.h16,
                    
                    _buildInvoiceRow('طريقة الدفع', 'نقدي للكابتن', isDark, isBold: true),
                    AppSpacing.h12,
                    _buildInvoiceRow('المسافة المقطوعة', '4.2 كم', isDark),
                    AppSpacing.h12,
                    _buildInvoiceRow('زمن الرحلة', '14 دقيقة', isDark),
                    AppSpacing.h12,
                    _buildInvoiceRow('الكابتن', 'محمد علي', isDark),
                  ],
                ),
              ),
              
              AppSpacing.h40,

              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to review/rating
                    context.go(LaffahRoutes.passengerHome);
                    // Usually you'd pop a bottom sheet for rating here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusMD,
                    ),
                  ),
                  child: const Text(
                    'تقييم الكابتن',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              AppSpacing.h16,
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => context.go(LaffahRoutes.passengerHome),
                  child: Text(
                    'العودة للرئيسية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.gray900,
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

  Widget _buildInvoiceRow(String label, String value, bool isDark, {bool isBold = false}) {
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
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),
      ],
    );
  }
}

