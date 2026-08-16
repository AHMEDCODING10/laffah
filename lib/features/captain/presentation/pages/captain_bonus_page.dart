import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../bloc/core/captain_bloc.dart';
import '../bloc/core/captain_event.dart';
import '../bloc/core/captain_state.dart';

class CaptainBonusPage extends StatefulWidget {
  const CaptainBonusPage({super.key});

  @override
  State<CaptainBonusPage> createState() => _CaptainBonusPageState();
}

class _CaptainBonusPageState extends State<CaptainBonusPage> {
  @override
  void initState() {
    super.initState();
    context.read<CaptainBloc>().add(const FetchBonusData());
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
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: isDark ? AppColors.white : AppColors.gray900),
            onPressed: () => Navigator.pop(context),
          ),
          centerTitle: true,
          title: Text(
            'المكافآت والبونص',
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w900,
              fontSize: 18,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: BlocBuilder<CaptainBloc, CaptainState>(
          builder: (context, state) {
            if (state is! CaptainBonusDataLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            final completed = state.completedTrips;
            final target = state.targetTrips;
            final bonus = state.bonusAmount;
            final progress = completed / target;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.s20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s20),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSpacing.radiusLG,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary500.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.emoji_events_rounded,
                            color: AppColors.white, size: 64),
                        AppSpacing.h16,
                        const Text(
                          'التارجت اليومي المستهدف',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        AppSpacing.h8,
                        Text(
                          'أكمل $target رحلات واحصل على',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                            color: AppColors.white,
                          ),
                        ),
                        AppSpacing.h4,
                        Text(
                          '${bonus.toStringAsFixed(0)} ريال بونص إضافي!',
                          style: const TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontWeight: FontWeight.w900,
                            fontSize: 24,
                            color: AppColors.warning, // Gold/yellow color
                          ),
                        ),
                        AppSpacing.h24,
                        // Progress Bar
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'الرحلات المنجزة: $completed',
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'المتبقي: ${target - completed}',
                                  style: const TextStyle(
                                    fontFamily: 'IBM Plex Sans Arabic',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            AppSpacing.h8,
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                backgroundColor: Colors.white24,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    AppColors.warning),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  AppSpacing.h32,

                  // Weekly Target
                  Text(
                    'بونص الأسبوع الحالي',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? AppColors.white : AppColors.gray900,
                    ),
                  ),
                  AppSpacing.h16,
                  _buildBonusCard(
                    title: 'التارجت الأسبوعي (50 رحلة)',
                    subtitle: 'أنجزت 25 رحلة حتى الآن',
                    reward: '15,000 ريال',
                    progress: 0.5,
                    isDark: isDark,
                  ),
                  AppSpacing.h16,
                  _buildBonusCard(
                    title: 'بونص التقييم العالي (4.9+)',
                    subtitle: 'تقييمك الحالي: 4.95',
                    reward: '5,000 ريال',
                    progress: 1.0,
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

  Widget _buildBonusCard({
    required String title,
    required String subtitle,
    required String reward,
    required double progress,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.s16),
      decoration: BoxDecoration(
        color:
            isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.white,
        borderRadius: AppSpacing.radiusMD,
        border: Border.all(
            color: isDark
                ? AppColors.white.withValues(alpha: 0.1)
                : AppColors.gray200),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: AppColors.gray200.withValues(alpha: 0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: progress == 1.0
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.primary500.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              progress == 1.0
                  ? Icons.check_circle_rounded
                  : Icons.monetization_on_rounded,
              color: progress == 1.0 ? AppColors.success : AppColors.primary500,
            ),
          ),
          AppSpacing.w16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h4,
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                AppSpacing.h8,
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: isDark
                        ? AppColors.white.withValues(alpha: 0.1)
                        : AppColors.gray200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0
                          ? AppColors.success
                          : AppColors.primary500,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.w16,
          Column(
            children: [
              Text(
                'المكافأة',
                style: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontSize: 10,
                  color: isDark ? AppColors.gray400 : AppColors.gray600,
                ),
              ),
              Text(
                reward,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
