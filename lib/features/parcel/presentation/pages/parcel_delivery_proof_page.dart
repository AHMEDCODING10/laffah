import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// ParcelDeliveryProofPage — Captain captures or passenger views the photo proof
/// of parcel delivery at the destination.
class ParcelDeliveryProofPage extends StatelessWidget {
  final bool
      isCaptainView; // If true, show camera button. If false, show image.

  const ParcelDeliveryProofPage({
    super.key,
    this.isCaptainView = true,
  });

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
            'تأكيد استلام الطرد',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'إثبات التسليم',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h8,
              Text(
                isCaptainView
                    ? 'يرجى التقاط صورة للطرد في موقع التسليم لتأكيد العملية وتوثيقها.'
                    : 'صورة توثيق تسليم الطرد من قبل الكابتن.',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 14,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                  height: 1.5,
                ),
              ),

              AppSpacing.h32,

              // Image Container / Camera Trigger
              Container(
                width: double.infinity,
                height: 300,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: AppSpacing.radiusLG,
                  border: Border.all(
                    color: isDark
                        ? AppColors.white.withValues(alpha: 0.1)
                        : AppColors.gray300,
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: isCaptainView
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF6B00)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: Color(0xFFFF6B00), size: 40),
                          ),
                          AppSpacing.h16,
                          Text(
                            'التقط صورة لإثبات التسليم',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.gray300
                                  : AppColors.gray700,
                            ),
                          ),
                        ],
                      )
                    : Center(
                        child: Icon(Icons.image_rounded,
                            size: 80,
                            color:
                                isDark ? AppColors.gray700 : AppColors.gray300),
                        // In real implementation, this would be NetworkImage or FileImage
                      ),
              ),

              AppSpacing.h40,

              if (isCaptainView)
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      // Submit proof and complete ride
                      context.pop();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B00),
                      foregroundColor: AppColors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                      ),
                    ),
                    child: const Text(
                      'تأكيد استلام الطرد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
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
