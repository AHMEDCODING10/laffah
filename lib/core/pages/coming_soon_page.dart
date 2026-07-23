import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// LaffahComingSoonPage — Production-grade interim screen for Laffah features
/// that are pending implementation in subsequent build phases.
class LaffahComingSoonPage extends StatefulWidget {
  final String featureNameAr;
  final String featureNameEn;
  final IconData iconData;

  const LaffahComingSoonPage({
    super.key,
    required this.featureNameAr,
    required this.featureNameEn,
    required this.iconData,
  });

  @override
  State<LaffahComingSoonPage> createState() => _LaffahComingSoonPageState();
}

class _LaffahComingSoonPageState extends State<LaffahComingSoonPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? AppColors.white : AppColors.gray900,
              size: 20,
            ),
            onPressed: () => Navigator.maybePop(context),
          ),
          centerTitle: true,
          title: Text(
            widget.featureNameAr,
            style: TextStyle(
              fontFamily: 'IBM Plex Sans Arabic',
              fontWeight: FontWeight.w700,
              fontSize: 17,
              color: isDark ? AppColors.white : AppColors.gray900,
            ),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s32,
              vertical: AppSpacing.s24,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated pulsing icon container
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: child,
                    );
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer glow ring
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary500.withValues(alpha: 0.06),
                          border: Border.all(
                            color: AppColors.primary500.withValues(alpha: 0.12),
                            width: 1.5,
                          ),
                        ),
                      ),
                      // Inner icon container
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary500.withValues(alpha: 0.12),
                        ),
                        child: Icon(
                          widget.iconData,
                          color: AppColors.primary500,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h32,

                // "Coming Soon" badge
                ClipRRect(
                  borderRadius: AppSpacing.radiusFull,
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s20,
                        vertical: AppSpacing.s8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.08),
                        borderRadius: AppSpacing.radiusFull,
                        border: Border.all(
                          color: AppColors.primary500.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.primary500,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'قريباً في التحديث القادم',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary500,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                AppSpacing.h24,

                // Feature name (Arabic)
                Text(
                  widget.featureNameAr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                    height: 1.3,
                  ),
                ),

                AppSpacing.h8,

                // Feature name (English)
                Text(
                  widget.featureNameEn,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.gray500,
                    letterSpacing: 0.5,
                  ),
                ),

                AppSpacing.h20,

                // Descriptive body text
                Container(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.surfaceDark
                        : AppColors.gray100,
                    borderRadius: AppSpacing.radiusMD,
                    border: Border.all(
                      color: isDark
                          ? AppColors.white.withValues(alpha: 0.04)
                          : AppColors.gray200,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: AppColors.gray500,
                      ),
                      AppSpacing.w12,
                      Expanded(
                        child: Text(
                          'هذه الميزة قيد التطوير النشط وستكون متاحة في الإصدار القادم من تطبيق لَفَّة. نعمل على توفيرها بأعلى مستوى من الجودة لتناسب سائقي الدراجات النارية في صنعاء.',
                          style: TextStyle(
                            fontFamily: 'IBM Plex Sans Arabic',
                            fontSize: 13,
                            height: 1.6,
                            color:
                            isDark ? AppColors.gray500 : AppColors.gray600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                AppSpacing.h40,

                // Return button
                SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.maybePop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary500,
                      foregroundColor: AppColors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: AppSpacing.radiusMD,
                      ),
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text(
                      'العودة',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                AppSpacing.h24,

                // Laffah branding footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'لَفَّة • دراجة نارية حصراً • صنعاء، اليمن',
                      style: TextStyle(
                        fontFamily: 'IBM Plex Sans Arabic',
                        fontSize: 11,
                        color: isDark ? AppColors.gray700 : AppColors.gray400,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.primary500.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
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
  }
}