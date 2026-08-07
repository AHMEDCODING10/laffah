import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';

/// ParcelConfirmationPage — Shown to passenger after successfully booking a parcel delivery.
class ParcelConfirmationPage extends StatelessWidget {
  const ParcelConfirmationPage({super.key});

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
            icon: Icon(Icons.close_rounded, color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => context.go(LaffahRoutes.passengerHome),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.s24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFF3B82F6),
                  size: 50,
                ),
              ),
              AppSpacing.h24,
              
              Text(
                'تم تأكيد طلب التوصيل',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              
              AppSpacing.h8,
              Text(
                'نحن نبحث الآن عن أقرب كابتن دراجة نارية لاستلام طردك.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  height: 1.5,
                ),
              ),
              
              AppSpacing.h40,

              // Tracking Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.s24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(
                    color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'رقم التتبع الخاص بك',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 14,
                        color: AppColors.gray500,
                      ),
                    ),
                    AppSpacing.h12,
                    const Text(
                      'LF-9321',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF3B82F6),
                        letterSpacing: 4,
                      ),
                    ),
                    AppSpacing.h24,
                    ElevatedButton.icon(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark ? AppColors.gray800 : AppColors.gray100,
                        foregroundColor: isDark ? AppColors.white : AppColors.gray900,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                          borderRadius: AppSpacing.radiusMD,
                        ),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 18),
                      label: const Text(
                        'نسخ رقم التتبع',
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              AppSpacing.h40,

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    context.go(LaffahRoutes.passengerParcelTracking);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B00),
                    foregroundColor: AppColors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppSpacing.radiusMD,
                    ),
                  ),
                  child: const Text(
                    'تتبع الطرد المباشر',
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
                height: 54,
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
}

