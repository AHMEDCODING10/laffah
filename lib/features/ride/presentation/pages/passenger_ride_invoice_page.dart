import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/passenger/trip_rating_bottom_sheet.dart';

class PassengerRideInvoicePage extends StatelessWidget {
  final double fare;
  final String tripId;
  final String captainName;
  final double discount;
  
  const PassengerRideInvoicePage({
    super.key,
    this.fare = 1200.0,
    this.tripId = 'LF-83210',
    this.captainName = 'محمد علي',
    this.discount = 0.0,
  });

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TripRatingBottomSheet(
        tripFare: fare,
        captainName: captainName,
        vehicleInfo: 'لَفّة • $tripId',
        onSubmitted: () {
          context.go('/passenger/home');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => context.go('/passenger/home'),
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
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Success Icon & Amount
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                    ),
                    AppSpacing.h16,
                    Text(
                      'تمت الرحلة بنجاح!',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isDark ? AppColors.gray400 : AppColors.gray600,
                      ),
                    ),
                    AppSpacing.h8,
                    Text(
                      '${(fare - discount).toStringAsFixed(0)} ريال',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 32,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,

              // Invoice Details Card
              Container(
                padding: const EdgeInsets.all(AppSpacing.s20),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.1) : AppColors.gray200),
                  boxShadow: isDark ? [] : [
                    BoxShadow(
                      color: AppColors.gray200.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildInvoiceRow('تكلفة الرحلة الأساسية', '${fare.toStringAsFixed(0)} ريال', isDark),
                    AppSpacing.h12,
                    _buildInvoiceRow('رسوم الخدمة', 'مجاناً', isDark, color: AppColors.success),
                    AppSpacing.h12,
                    _buildInvoiceRow('خصم برومو كود', '- ${discount.toStringAsFixed(0)} ريال', isDark, color: AppColors.success),
                    const Divider(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'الإجمالي',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                            color: isDark ? AppColors.white : AppColors.gray900,
                          ),
                        ),
                        Text(
                          '${(fare - discount).toStringAsFixed(0)} ريال',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                            color: AppColors.primary500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.h32,
              
              // CTA: Rate Captain
              ElevatedButton(
                onPressed: () => _showRatingSheet(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary500,
                  minimumSize: const Size(double.infinity, 52),
                  shape: const RoundedRectangleBorder(borderRadius: AppSpacing.radiusMD),
                ),
                child: const Text(
                  'تقييم الكابتن وإضافة بقشيش',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String title, String value, bool isDark, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontSize: 14,
            color: isDark ? AppColors.gray400 : AppColors.gray600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: color ?? (isDark ? AppColors.white : AppColors.gray900),
          ),
        ),
      ],
    );
  }
}
