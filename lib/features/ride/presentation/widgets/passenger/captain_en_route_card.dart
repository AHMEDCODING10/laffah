import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';
import '../../../../../core/widgets/glass_box.dart';

/// CaptainEnRouteCard — Active bottom sheet card shown when a captain accepted the ride
class CaptainEnRouteCard extends StatelessWidget {
  final String captainName;
  final String motorcycleModel;
  final String licensePlate;
  final double rating;
  final String eta;
  final VoidCallback onCall;
  final VoidCallback onMessage;
  final VoidCallback onCancel;

  const CaptainEnRouteCard({
    super.key,
    required this.captainName,
    required this.motorcycleModel,
    required this.licensePlate,
    required this.rating,
    required this.eta,
    required this.onCall,
    required this.onMessage,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: GlassBox(
        borderRadius: AppSpacing.radiusBottomSheet,
        customBgColor: isDark 
            ? const Color(0xFF111827).withOpacity(0.95) 
            : Colors.white.withOpacity(0.95),
        padding: const EdgeInsets.only(
          top: AppSpacing.s16,
          bottom: AppSpacing.s24,
          left: AppSpacing.s20,
          right: AppSpacing.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.15),
                  borderRadius: AppSpacing.radiusXS,
                ),
              ),
            ),
            AppSpacing.h16,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الكابتن في الطريق إليك',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: isDark ? AppColors.white : AppColors.gray900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'يصل خلال $eta',
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B00),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s8),
                  decoration: BoxDecoration(
                    color: AppColors.danger.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppColors.danger,
                    size: 20,
                  ),
                ),
              ],
            ),
            
            AppSpacing.h20,

            Container(
              padding: const EdgeInsets.all(AppSpacing.s12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.white.withOpacity(0.03) : AppColors.gray50,
                borderRadius: AppSpacing.radiusMD,
                border: Border.all(
                  color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B00),
                        width: 2,
                      ),
                      image: const DecorationImage(
                        image: AssetImage('assets/images/default_avatar.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: const Icon(Icons.person_rounded, color: Colors.white24, size: 30),
                  ),
                  AppSpacing.w16,
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              captainName,
                              style: TextStyle(
                                fontFamily: 'IBM Plex Sans Arabic',
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: isDark ? AppColors.white : AppColors.gray900,
                              ),
                            ),
                            AppSpacing.w8,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFF6B00).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Color(0xFFFF6B00), size: 12),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFFF6B00),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        AppSpacing.h4,
                        Text(
                          motorcycleModel,
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 12,
                            color: isDark ? AppColors.gray400 : AppColors.gray600,
                          ),
                        ),
                        AppSpacing.h4,
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.black26),
                          ),
                          child: Text(
                            licensePlate,
                            style: const TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.s10),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.white.withOpacity(0.05) : AppColors.gray200,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.motorcycle_rounded,
                      color: Color(0xFFFF6B00),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            
            AppSpacing.h24,

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E).withOpacity(0.15),
                      foregroundColor: const Color(0xFF22C55E),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                        side: const BorderSide(color: Color(0xFF22C55E), width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.call_rounded, size: 20),
                    label: const Text(
                      'اتصال',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                AppSpacing.w12,
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMessage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6).withOpacity(0.15),
                      foregroundColor: const Color(0xFF3B82F6),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                        side: const BorderSide(color: Color(0xFF3B82F6), width: 1),
                      ),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                    label: const Text(
                      'رسالة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            AppSpacing.h16,
            
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: BorderSide(color: AppColors.danger.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.radiusMD,
                  ),
                ),
                child: const Text(
                  'إلغاء الرحلة',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
