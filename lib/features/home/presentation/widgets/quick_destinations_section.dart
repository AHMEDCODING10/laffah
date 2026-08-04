import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// QuickDestinationsSection — Horizontal row of 4 circular quick destination buttons
/// (Saved places, University, Work, Home).
class QuickDestinationsSection extends StatelessWidget {
  final bool isDark;
  final List<Map<String, dynamic>> destinations;
  final int selectedIndex;
  final Function(int index, Map<String, dynamic> dest) onDestinationSelected;

  const QuickDestinationsSection({
    super.key,
    required this.isDark,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'وجهات سريعة',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            GestureDetector(
              onTap: () {
                context.push(LaffahRoutes.passengerSavedPlaces);
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 15,
                  color: AppColors.primary500,
                ),
              ),
            ),
          ],
        ),

        AppSpacing.h12,

        // Horizontal Row of 4 Circular Destination Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(destinations.length, (index) {
            final dest = destinations[index];
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onDestinationSelected(index, dest),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary500.withValues(alpha: 0.15)
                          : (isDark
                              ? AppColors.surfaceElevatedDark
                              : AppColors.gray100),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary500
                            : (isDark
                                ? AppColors.white.withValues(alpha: 0.08)
                                : AppColors.gray300),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color:
                                    AppColors.primary500.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      dest['icon'] as IconData,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark ? AppColors.gray300 : AppColors.gray700),
                      size: 24,
                    ),
                  ),
                  AppSpacing.h6,
                  Text(
                    dest['title'] as String,
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary500
                          : (isDark ? AppColors.gray300 : AppColors.gray800),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}
