import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

enum SnackBarType { success, error, warning, info }

/// LaffahSnackBar — Ultra-modern glassmorphic floating notifications system
/// Floats gracefully above bottom navigation bars without covering user controls.
class LaffahSnackBar {
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.success);
  }

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.error);
  }

  static void showWarning(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    show(context, message: message, type: SnackBarType.info);
  }

  // Convenient short aliases
  static void success(BuildContext context, String message) => showSuccess(context, message);
  static void error(BuildContext context, String message) => showError(context, message);
  static void warning(BuildContext context, String message) => showWarning(context, message);
  static void info(BuildContext context, String message) => showInfo(context, message);

  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticFeedback.lightImpact();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color themeColor;
    IconData icon;

    switch (type) {
      case SnackBarType.success:
        themeColor = const Color(0xFF00C853);
        icon = Icons.check_circle_rounded;
        break;
      case SnackBarType.error:
        themeColor = const Color(0xFFFF3B30);
        icon = Icons.error_outline_rounded;
        break;
      case SnackBarType.warning:
        themeColor = const Color(0xFFFF9100);
        icon = Icons.warning_amber_rounded;
        break;
      case SnackBarType.info:
        themeColor = AppColors.primary500;
        icon = Icons.info_outline_rounded;
        break;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 92),
        padding: EdgeInsets.zero,
        content: Directionality(
          textDirection: TextDirection.rtl,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF141923).withValues(alpha: 0.92)
                      : Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: themeColor.withValues(alpha: isDark ? 0.35 : 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: themeColor.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: themeColor.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        icon,
                        color: themeColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        message,
                        style: TextStyle(
                          fontFamily: 'IBM Plex Sans Arabic',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.gray900,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
