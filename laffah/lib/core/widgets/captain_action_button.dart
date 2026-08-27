import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// CaptainActionButton - Custom action button built for Android ergonomics & Haptic feedback.
/// Ensures minimum 48dp (or 56dp height) touch target size suitable for drivers with gloves.
class CaptainActionButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? backgroundColor;
  final Color textColor;
  final bool isFullWidth;
  final bool isLoading;
  final bool isOutlined;
  final double height;

  const CaptainActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.backgroundColor,
    this.textColor = Colors.white,
    this.isFullWidth = true,
    this.isLoading = false,
    this.isOutlined = false,
    this.height = 56.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primary500;

    Widget childContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      children: [
        if (isLoading) ...[
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                isOutlined ? effectiveBg : textColor,
              ),
            ),
          ),
          AppSpacing.w10,
        ] else if (icon != null) ...[
          Icon(icon, size: 22, color: isOutlined ? effectiveBg : textColor),
          AppSpacing.w8,
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'IBM Plex Sans Arabic',
            color: isOutlined ? effectiveBg : textColor,
          ),
        ),
      ],
    );

    return SizedBox(
      height: height,
      width: isFullWidth ? double.infinity : null,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed == null
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      onPressed!();
                    },
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: effectiveBg, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: AppSpacing.borderMD,
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
              ),
              child: childContent,
            )
          : Container(
              decoration: BoxDecoration(
                gradient:
                    backgroundColor == null ? AppColors.primaryGradient : null,
                color: backgroundColor,
                borderRadius: AppSpacing.borderMD,
                boxShadow: onPressed != null
                    ? [
                        BoxShadow(
                          color: effectiveBg.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: ElevatedButton(
                onPressed: onPressed == null
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        onPressed!();
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppSpacing.borderMD,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                ),
                child: childContent,
              ),
            ),
    );
  }
}
