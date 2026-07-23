import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// GlassBox - A highly polished Glassmorphism container
/// Implements: Blur 28, Translucent background, Elegant borders, Custom corners.
class GlassBox extends StatelessWidget {
  final Widget child;
  final double? width;
  final double? height;

  /// Dynamic radius handling both double and BorderRadiusGeometry seamlessly
  final dynamic borderRadius;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? customBgColor;
  final Color? customBorderColor;

  const GlassBox({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = AppSpacing.radiusLG,
    this.padding = const EdgeInsets.all(AppSpacing.s16),
    this.margin,
    this.customBgColor,
    this.customBorderColor,
  });

  /// Helper to strictly convert any radius input (double or BorderRadius) to BorderRadius
  BorderRadius _resolvedBorderRadius() {
    if (borderRadius is double) {
      return BorderRadius.circular(borderRadius as double);
    } else if (borderRadius is BorderRadius) {
      return borderRadius as BorderRadius;
    } else if (borderRadius is BorderRadiusGeometry) {
      return borderRadius as BorderRadius;
    }
    return AppSpacing.radiusLG;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius = _resolvedBorderRadius();

    // Translucent background based on specifications
    final defaultBgColor = isDark
        ? AppColors.backgroundDark.withValues(alpha: 0.68)
        : AppColors.white.withValues(alpha: 0.68);

    // Subtle premium border reflective of light
    final defaultBorderColor = isDark
        ? AppColors.white.withValues(alpha: 0.12)
        : AppColors.white.withValues(alpha: 0.18);

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : AppColors.gray900.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          // Strict Blur 28 matching Laffah Design System Specification
          filter: ImageFilter.blur(sigmaX: 28.0, sigmaY: 28.0),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              color: customBgColor ?? defaultBgColor,
              borderRadius: effectiveRadius,
              border: Border.all(
                color: customBorderColor ?? defaultBorderColor,
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}