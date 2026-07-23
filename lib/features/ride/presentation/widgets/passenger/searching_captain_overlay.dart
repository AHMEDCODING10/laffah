import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_spacing.dart';

/// SearchingCaptainOverlay — Animated loading overlay when searching for nearby captains.
class SearchingCaptainOverlay extends StatefulWidget {
  final VoidCallback onCancel;

  const SearchingCaptainOverlay({
    super.key,
    required this.onCancel,
  });

  @override
  State<SearchingCaptainOverlay> createState() => _SearchingCaptainOverlayState();
}

class _SearchingCaptainOverlayState extends State<SearchingCaptainOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
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
      child: Stack(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              color: isDark
                  ? const Color(0xFF0E1116).withOpacity(0.7)
                  : Colors.white.withOpacity(0.7),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 160 * _pulseAnimation.value,
                          height: 160 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6B00).withOpacity(0.1),
                          ),
                        ),
                        Container(
                          width: 110 * _pulseAnimation.value,
                          height: 110 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFFF6B00).withOpacity(0.2),
                          ),
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFFF6B00),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x66FF6B00),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.motorcycle_rounded,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                AppSpacing.h40,
                Text(
                  'جاري البحث عن كابتن لَفَّة...',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.white : AppColors.gray900,
                  ),
                ),
                AppSpacing.h12,
                Text(
                  'نبحث عن أقرب دراجة نارية لموقعك',
                  style: TextStyle(
                    fontFamily: 'IBM Plex Sans Arabic',
                    fontSize: 14,
                    color: isDark ? AppColors.gray400 : AppColors.gray600,
                  ),
                ),
                AppSpacing.h48,
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: widget.onCancel,
                    borderRadius: AppSpacing.radiusFull,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.s32,
                        vertical: AppSpacing.s12,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.white.withOpacity(0.05)
                            : AppColors.gray200,
                        borderRadius: AppSpacing.radiusFull,
                        border: Border.all(
                          color: isDark
                              ? AppColors.white.withOpacity(0.1)
                              : AppColors.gray300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            color: isDark ? AppColors.white : AppColors.gray900,
                            size: 18,
                          ),
                          AppSpacing.w8,
                          Text(
                            'إلغاء الطلب',
                            style: TextStyle(
                              fontFamily: 'IBM Plex Sans Arabic',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.white : AppColors.gray900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
