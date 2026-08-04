import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/laffah_map_view.dart';
import '../../../../core/widgets/glass_box.dart';

/// ParcelTrackingPage — Live tracking for passenger's parcel deliveries.
/// Includes map view and timeline of delivery states.
class ParcelTrackingPage extends StatelessWidget {
  const ParcelTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // Map View
            Positioned.fill(
              child: LaffahMapView(
                isDark: isDark,
              ),
            ),
            
            // Top Action Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + AppSpacing.s12,
              left: AppSpacing.s16,
              right: AppSpacing.s16,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_rounded,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      borderRadius: AppSpacing.radiusFull,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_rounded, color: Color(0xFF3B82F6), size: 16),
                        AppSpacing.w8,
                        Text(
                          'قيد التوصيل',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.white : AppColors.gray900,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Info Sheet
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: GlassBox(
                borderRadius: AppSpacing.radiusBottomSheet,
                customBgColor: isDark 
                    ? const Color(0xFF111827).withValues(alpha: 0.95) 
                    : Colors.white.withValues(alpha: 0.95),
                padding: EdgeInsets.only(
                  top: AppSpacing.s24,
                  bottom: MediaQuery.of(context).padding.bottom + 16,
                  left: AppSpacing.s20,
                  right: AppSpacing.s20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Tracking ID
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'معرف الطلب: #LF-9321',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                        const Text(
                          'يصل خلال 12 دقيقة',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                    
                    AppSpacing.h24,
                    
                    // Timeline
                    _buildTimeline(isDark),
                    
                    AppSpacing.h24,
                    
                    // Captain Info
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.s12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withValues(alpha: 0.03) : AppColors.gray50,
                        borderRadius: AppSpacing.radiusMD,
                        border: Border.all(
                          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.gray800 : AppColors.gray200,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded, color: Colors.grey),
                          ),
                          AppSpacing.w16,
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'محمد علي',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: isDark ? AppColors.white : AppColors.gray900,
                                  ),
                                ),
                                Text(
                                  'دراجة نارية سوزوكي • 10293',
                                  style: TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontSize: 12,
                                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.call_rounded, color: Color(0xFF22C55E)),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline(bool isDark) {
    return Column(
      children: [
        _buildTimelineStep(
          title: 'تم استلام الطلب',
          time: '10:00 ص',
          isCompleted: true,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'الكابتن استلم الطرد',
          time: '10:15 ص',
          isCompleted: true,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'في الطريق إلى المستلم',
          time: 'الآن',
          isCompleted: false,
          isActive: true,
          isLast: false,
          isDark: isDark,
        ),
        _buildTimelineStep(
          title: 'تم التسليم بنجاح',
          time: 'متوقع 10:45 ص',
          isCompleted: false,
          isLast: true,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String time,
    required bool isCompleted,
    bool isActive = false,
    required bool isLast,
    required bool isDark,
  }) {
    final Color color = isCompleted 
        ? const Color(0xFF22C55E) 
        : (isActive ? const Color(0xFF3B82F6) : (isDark ? AppColors.gray600 : AppColors.gray300));
        
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: isCompleted || isActive ? color : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: 2,
                ),
              ),
              child: isCompleted 
                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 10) 
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 30,
                color: isCompleted ? const Color(0xFF22C55E) : (isDark ? AppColors.gray600 : AppColors.gray300),
              ),
          ],
        ),
        AppSpacing.w16,
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    fontWeight: isActive || isCompleted ? FontWeight.w700 : FontWeight.w400,
                    color: isActive || isCompleted 
                        ? (isDark ? AppColors.white : AppColors.gray900)
                        : (isDark ? AppColors.gray400 : AppColors.gray600),
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isActive || isCompleted 
                        ? (isDark ? AppColors.white : AppColors.gray900)
                        : (isDark ? AppColors.gray400 : AppColors.gray600),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

