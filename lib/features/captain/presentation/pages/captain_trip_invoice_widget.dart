import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';
import '../../../../core/widgets/captain_action_button.dart';

/// CaptainTripInvoiceWidget - Premium visual invoice summary presented after trip completion
class CaptainTripInvoiceWidget extends StatelessWidget {
  final double fare;
  final String distance;
  final String duration;
  final String pickup;
  final String dropoff;
  final String paymentMethod;
  final VoidCallback onFinish;

  const CaptainTripInvoiceWidget({
    super.key,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.pickup,
    required this.dropoff,
    this.paymentMethod = 'نقداً (Cash)',
    required this.onFinish,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1116) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'ملخص الرحلة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            fontFamily: 'IBM Plex Sans Arabic',
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Success circular badge
              Center(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: const BoxDecoration(
                      color: AppColors.primary500,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),

              AppSpacing.h20,

              // Success title and subtitle
              const Text(
                'تمت الرحلة بنجاح',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),
              AppSpacing.h6,
              const Text(
                'شكراً لك يا كابتن! يومك حافل بالإنجاز.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.gray500,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'IBM Plex Sans Arabic',
                ),
              ),

              AppSpacing.h32,

              // Invoice Details Glass Box Card
              GlassBox(
                borderRadius: AppSpacing.radiusLG,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s24),
                child: Column(
                  children: [
                    const Text(
                      'إجمالي قيمة المشوار',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray500,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    AppSpacing.h4,
                    Text(
                      '${fare.toStringAsFixed(0)} ريال',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary500,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                    
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.s16),
                      child: Divider(height: 1),
                    ),

                    // Cash indicator & specs rows
                    _buildInvoiceRow('طريقة الدفع', paymentMethod),
                    AppSpacing.h12,
                    _buildInvoiceRow('المسافة', distance),
                    AppSpacing.h12,
                    _buildInvoiceRow('وقت الرحلة', duration),
                    AppSpacing.h12,
                    _buildInvoiceRow('المسار', 'من ${pickup.split('،').first} إلى ${dropoff.split('،').first}'),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Bottom Actions (تم التحصيل & العودة للرئيسية)
              CaptainActionButton(
                label: 'تم التحصيل كاش',
                icon: Icons.payments_rounded,
                onPressed: onFinish,
              ),

              AppSpacing.h12,

              CaptainActionButton(
                label: 'العودة للرئيسية',
                icon: Icons.home_rounded,
                isOutlined: true,
                onPressed: onFinish,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.gray500, fontWeight: FontWeight.bold, fontFamily: 'IBM Plex Sans Arabic'),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, fontFamily: 'IBM Plex Sans Arabic'),
        ),
      ],
    );
  }
}
