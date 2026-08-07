import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/glass_box.dart';

class HomeIdleInputCard extends StatelessWidget {
  final TextEditingController pickupController;
  final TextEditingController dropoffController;
  final VoidCallback onShowRideSelection;
  final VoidCallback onShowParcelForm;
  final List<Map<String, dynamic>> quickDestinations;
  final Function(String) onQuickDestinationSelected;

  const HomeIdleInputCard({
    super.key,
    required this.pickupController,
    required this.dropoffController,
    required this.onShowRideSelection,
    required this.onShowParcelForm,
    required this.quickDestinations,
    required this.onQuickDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s20, vertical: AppSpacing.s20),
      child: GlassBox(
        borderRadius: AppSpacing.radiusLG,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'أين تريد الذهاب اليوم في لفة؟',
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
            ),
            AppSpacing.h16,
            HomeAddressInputField(
              controller: pickupController,
              icon: Icons.my_location_rounded,
              iconColor: AppColors.success,
              hint: 'موقع الانطلاق الحالي...',
              isDark: isDark,
            ),
            AppSpacing.h12,
            HomeAddressInputField(
              controller: dropoffController,
              icon: Icons.location_on_rounded,
              iconColor: AppColors.danger,
              hint: 'اكتب وجهة وصولك...',
              isDark: isDark,
            ),
            AppSpacing.h20,
            Container(
              height: 52,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: AppSpacing.radiusMD,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary500.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: onShowRideSelection,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: AppColors.white,
                  shadowColor: Colors.transparent,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'أكد وجهتك واحسب الأجرة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        color: AppColors.white,
                      ),
                    ),
                    AppSpacing.w10,
                    Icon(Icons.arrow_forward_rounded, size: 18, color: AppColors.white),
                  ],
                ),
              ),
            ),
            AppSpacing.h12,
            SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: onShowParcelForm,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary500,
                  side: BorderSide(color: AppColors.primary500.withValues(alpha: 0.5), width: 1.5),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.inventory_2_rounded, size: 18),
                    AppSpacing.w10,
                    Text(
                      'توصيل طرد',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AppSpacing.h16,
            const Divider(color: Colors.white10, height: 1),
            AppSpacing.h12,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المواقع المفضلة السريعة:',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.push('/passenger/profile/saved-places'),
                  child: const Text(
                    'عرض الكل ›',
                    style: TextStyle(
                      fontFamily: 'IBM Plex Sans Arabic',
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.h10,
            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickDestinations.length,
                separatorBuilder: (ctx, index) => AppSpacing.w8,
                itemBuilder: (ctx, index) {
                  final dest = quickDestinations[index];
                  return GestureDetector(
                    onTap: () => onQuickDestinationSelected(dest['title']),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.04) : AppColors.gray200),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(dest['icon'] as IconData, size: 15, color: AppColors.primary500),
                          AppSpacing.w6,
                          Text(
                            dest['title'] as String,
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.white : AppColors.gray800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeAddressInputField extends StatelessWidget {
  final TextEditingController controller;
  final IconData icon;
  final Color iconColor;
  final String hint;
  final bool isDark;

  const HomeAddressInputField({
    super.key,
    required this.controller,
    required this.icon,
    required this.iconColor,
    required this.hint,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark ? AppColors.white.withValues(alpha: 0.02) : AppColors.gray50,
        borderRadius: AppSpacing.radiusSM,
        border: Border.all(color: isDark ? AppColors.white.withValues(alpha: 0.05) : AppColors.gray300),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 18),
          AppSpacing.w12,
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: 'IBM Plex Sans Arabic',
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? AppColors.white : AppColors.gray900,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  fontFamily: 'IBM Plex Sans Arabic',
                  fontWeight: FontWeight.normal,
                  fontSize: 13,
                  color: isDark ? AppColors.gray600 : AppColors.gray400,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
