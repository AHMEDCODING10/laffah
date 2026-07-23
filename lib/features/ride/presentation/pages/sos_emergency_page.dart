import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';

/// SOSEmergencyPage — Critical safety screen for Laffah passengers and captains.
/// Allows instant contact with emergency services or Laffah safety team.
///
/// Design: High-contrast Danger Red theme to indicate urgency.
class SOSEmergencyPage extends StatelessWidget {
  const SOSEmergencyPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Force dark background for this critical screen to make red pop
    const isDark = true; 

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                
                // Pulsing SOS Icon
                TweenAnimationBuilder(
                  tween: Tween<double>(begin: 0.8, end: 1.2),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  builder: (context, double val, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140 * val,
                          height: 140 * val,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger.withOpacity(0.15),
                          ),
                        ),
                        Container(
                          width: 100 * val,
                          height: 100 * val,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger.withOpacity(0.3),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.danger,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.danger,
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.shield_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                AppSpacing.h32,
                
                const Text(
                  'حالة طوارئ؟',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                
                AppSpacing.h12,
                
                const Text(
                  'فريق لَفَّة لسلامة الركاب والكباتن متواجد لخدمتك. اختر الجهة المناسبة للاتصال فوراً.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    color: AppColors.gray400,
                    height: 1.5,
                  ),
                ),
                
                const Spacer(),
                
                // Call Police
                _buildEmergencyButton(
                  title: 'الشرطة (النجدة)',
                  subtitle: 'اتصال فوري برقم 199',
                  icon: Icons.local_police_rounded,
                  color: const Color(0xFF3B82F6),
                  onTap: () {
                    // Logic to launch phone dialer with 199
                  },
                ),
                
                AppSpacing.h16,
                
                // Call Ambulance
                _buildEmergencyButton(
                  title: 'الإسعاف',
                  subtitle: 'اتصال فوري برقم 191',
                  icon: Icons.medical_services_rounded,
                  color: const Color(0xFF10B981),
                  onTap: () {
                    // Logic to launch phone dialer with 191
                  },
                ),
                
                AppSpacing.h16,
                
                // Call Laffah Safety Team
                _buildEmergencyButton(
                  title: 'فريق استجابة لَفَّة',
                  subtitle: 'الإبلاغ عن حادث أو مشكلة أمان',
                  icon: Icons.support_agent_rounded,
                  color: const Color(0xFFFF6B00),
                  onTap: () {
                    // Logic to call Laffah support
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyButton({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSpacing.radiusMD,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.s16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: AppSpacing.radiusMD,
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              AppSpacing.w16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.call_rounded, color: color, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

