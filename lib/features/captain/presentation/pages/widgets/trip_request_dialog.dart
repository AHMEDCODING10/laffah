import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';

/// TripRequestDialog - Premium Glassmorphic bottom-card/overlay matching Screenshot 1
/// that informs the captain of an incoming ride request with complete details in Arabic.
class TripRequestDialog extends StatelessWidget {
  final String passengerName;
  final double passengerRating;
  final String pickup;
  final String dropoff;
  final double fare;
  final String distance;
  final String duration;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const TripRequestDialog({
    super.key,
    required this.passengerName,
    required this.passengerRating,
    required this.pickup,
    required this.dropoff,
    required this.fare,
    required this.distance,
    required this.duration,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.s16, vertical: AppSpacing.s24),
      child: GlassBox(
        borderRadius: AppSpacing.radiusXL,
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header with custom badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top vehicle circle avatar decoration
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s10),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: AppColors.primary500,
                    size: 24,
                  ),
                ),
                // "New request" Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12, vertical: AppSpacing.s6),
                  decoration: BoxDecoration(
                    color: AppColors.primary500.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'طلب جديد',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary500,
                      fontFamily: 'IBM Plex Sans Arabic',
                    ),
                  ),
                ),
              ],
            ),
            
            AppSpacing.h16,

            // "New Trip Request" Title
            const Text(
              'طلب رحلة جديد',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontFamily: 'IBM Plex Sans Arabic',
              ),
            ),

            AppSpacing.h16,

            // Route representation
            Column(
              children: [
                // Pickup
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.primary500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'نقطة الاستلام',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            pickup,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Dashed connector
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Row(
                    children: [
                      Container(
                        width: 2,
                        height: 24,
                        color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                      ),
                    ],
                  ),
                ),

                // Dropoff
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        color: AppColors.info,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.w12,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'الوجهة',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gray500,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                          Text(
                            dropoff,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'IBM Plex Sans Arabic',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            AppSpacing.h24,

            // Spec row (Distance, Fare, Time)
            Row(
              children: [
                // Distance spec
                Expanded(
                  child: _buildSpecCard(
                    context,
                    isDark,
                    Icons.map_rounded,
                    'المسافة',
                    distance,
                  ),
                ),
                AppSpacing.w12,
                // Price spec
                Expanded(
                  child: _buildSpecCard(
                    context,
                    isDark,
                    Icons.payments_rounded,
                    'السعر',
                    '${fare.toStringAsFixed(0)} ريال',
                  ),
                ),
                AppSpacing.w12,
                // Time spec
                Expanded(
                  child: _buildSpecCard(
                    context,
                    isDark,
                    Icons.schedule_rounded,
                    'الوقت',
                    duration,
                  ),
                ),
              ],
            ),

            AppSpacing.h24,

            // Buttons
            Row(
              children: [
                // Reject Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                      side: BorderSide(
                        color: isDark ? AppColors.white.withOpacity(0.12) : AppColors.gray300,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.borderMD,
                      ),
                    ),
                    child: Text(
                      'رفض',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.white : AppColors.gray800,
                        fontFamily: 'IBM Plex Sans Arabic',
                      ),
                    ),
                  ),
                ),
                
                AppSpacing.w16,

                // Accept Button
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: AppSpacing.borderMD,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary500.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s14),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppSpacing.borderMD,
                        ),
                      ),
                      child: const Text(
                        'قبول',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          fontFamily: 'IBM Plex Sans Arabic',
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Helper builder for specs bento cards
  Widget _buildSpecCard(BuildContext context, bool isDark, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12, horizontal: AppSpacing.s8),
      decoration: BoxDecoration(
        color: isDark 
            ? AppColors.white.withOpacity(0.04) 
            : AppColors.gray100.withOpacity(0.8),
        borderRadius: AppSpacing.borderLG,
        border: Border.all(
          color: isDark ? AppColors.white.withOpacity(0.04) : AppColors.gray200,
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primary500,
          ),
          AppSpacing.h6,
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.gray500,
              fontWeight: FontWeight.bold,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
          AppSpacing.h4,
          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              fontFamily: 'IBM Plex Sans Arabic',
            ),
          ),
        ],
      ),
    );
  }
}
