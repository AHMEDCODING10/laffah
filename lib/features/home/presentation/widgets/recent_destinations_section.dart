import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// RecentDestinationsSection — Vertical list of recent passenger destinations
/// with titles, subtitles, distances, and quick ride triggers.
class RecentDestinationsSection extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> recentDestinations;
  final Function(Map<String, dynamic> item) onRecentSelected;

  const RecentDestinationsSection({
    super.key,
    required this.isDark,
    required this.recentDestinations,
    required this.onRecentSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'آخر الوجهات',
          style: TextStyle(
            fontFamily: 'IBM Plex Sans Arabic',
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? AppColors.white : AppColors.gray900,
          ),
        ),

        AppSpacing.h10,

        // Vertical List of Recent Destinations
        Column(
          children: List.generate(recentDestinations.length, (index) {
            final item = recentDestinations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.s8),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onRecentSelected(item),
                  borderRadius: AppSpacing.radiusSM,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.s12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.surfaceElevatedDark.withValues(alpha: 0.6)
                          : AppColors.gray50,
                      borderRadius: AppSpacing.radiusSM,
                      border: Border.all(
                        color: isDark
                            ? AppColors.white.withValues(alpha: 0.05)
                            : AppColors.gray200,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Right Icon (RTL)
                        Container(
                          padding: const EdgeInsets.all(AppSpacing.s8),
                          decoration: BoxDecoration(
                            color: AppColors.primary500.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            color: AppColors.primary500,
                            size: 20,
                          ),
                        ),

                        AppSpacing.w12,

                        // Title and Subtitle
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                  color: isDark
                                      ? AppColors.white
                                      : AppColors.gray900,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item['subtitle'] as String,
                                style: TextStyle(
                                  fontFamily: 'IBM Plex Sans Arabic',
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.gray400
                                      : AppColors.gray600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Left Distance Info (RTL -> Left side)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.near_me_rounded,
                              size: 13,
                              color: AppColors.gray500,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              item['distance'] as String,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.gray400
                                    : AppColors.gray700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
