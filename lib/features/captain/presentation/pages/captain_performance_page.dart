import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/router/app_router.dart';
import '../../../profile/presentation/bloc/profile_bloc.dart';
import '../../../profile/presentation/bloc/profile_state.dart';

/// CaptainPerformancePage — A dashboard for Captains to view their rating,
/// acceptance rate, cancellation rate, and overall performance metrics.
class CaptainPerformancePage extends StatelessWidget {
  const CaptainPerformancePage({super.key});

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
            'مؤشرات الأداء',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            String rating = '4.8';
            if (state is ProfileLoaded) {
              // rating from profile
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating Overview
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color(0xFF1E293B), isDark ? const Color(0xFF0F172A) : const Color(0xFF334155)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: AppSpacing.radiusLG,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFFF6B00), width: 3),
                          ),
                          child: Center(
                            child: Text(
                              rating,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        AppSpacing.w24,
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'التقييم العام',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'أداء ممتاز! حافظ على هذا المستوى للحصول على المزيد من طلبات التوصيل.',
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 12,
                                  color: Colors.white54,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  AppSpacing.h32,
                  
                  Text(
                    'المؤشرات الرئيسية',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h16,
              
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: 'معدل القبول',
                      value: '92%',
                      subtitle: 'مرتفع',
                      icon: Icons.thumb_up_rounded,
                      color: const Color(0xFF22C55E),
                      isDark: isDark,
                    ),
                  ),
                  AppSpacing.w16,
                  Expanded(
                    child: _buildMetricCard(
                      title: 'معدل الإلغاء',
                      value: '4%',
                      subtitle: 'جيد جداً',
                      icon: Icons.cancel_rounded,
                      color: const Color(0xFF3B82F6),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              AppSpacing.h16,
              
              // Feedback from passengers
              Text(
                'آراء الركاب الأخيرة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
              AppSpacing.h16,
              _buildReviewItem(
                rating: 5,
                comment: 'دراجة نظيفة وقيادة آمنة جداً. شكراً للكابتن.',
                date: 'منذ يومين',
                isDark: isDark,
              ),
              _buildReviewItem(
                rating: 4,
                comment: 'وصل في الوقت المحدد تماماً.',
                date: 'منذ 3 أيام',
                isDark: isDark,
              ),
              _buildReviewItem(
                rating: 5,
                comment: 'تعامل راقي ومحترم.',
                date: 'منذ أسبوع',
                isDark: isDark,
              ),
            ],
          ),
        );
      },
    ),
  ),
);
}

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 24),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: isDark ? AppColors.white : AppColors.gray900,
                ),
              ),
            ],
          ),
          AppSpacing.h12,
          Text(
            title,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem({
    required int rating,
    required String comment,
    required String date,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.s12),
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
          color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star_rounded : Icons.star_border_rounded,
                    color: const Color(0xFFFF6B00),
                    size: 16,
                  );
                }),
              ),
              Text(
                date,
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 11,
                  color: isDark ? AppColors.gray500 : AppColors.gray400,
                ),
              ),
            ],
          ),
          AppSpacing.h8,
          Text(
            comment,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontSize: 13,
              color: isDark ? AppColors.gray300 : AppColors.gray700,
            ),
          ),
        ],
      ),
    );
  }
}

