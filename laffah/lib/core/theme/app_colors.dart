import 'package:flutter/material.dart';

/// Laffah Color Palette System
/// Strict adherence to the Laffah (لفّة) Design System V2.0
class AppColors {
  AppColors._();

  // ==========================================
  // Primary Colors (Yemeni Orange Identity)
  // ==========================================
  static const Color primary50 = Color(0xFFFFF4E5);
  static const Color primary100 = Color(0xFFFFE0B2);
  static const Color primary200 = Color(0xFFFFCC80);
  static const Color primary300 = Color(0xFFFFB74D);
  static const Color primary400 = Color(0xFFFFA726);
  static const Color primary500 = Color(0xFFFF9800); // Core primary orange
  static const Color primary600 = Color(0xFFFB8C00);
  static const Color primary700 = Color(0xFFF57C00);
  static const Color primary800 = Color(0xFFEF6C00);
  static const Color primary900 = Color(0xFFE65100);

  // Core Primary Aliases
  static const Color primary = primary500;
  static const Color primaryDark = primary700;

  // Primary Gradients
  static const Color gradientStart = Color(0xFFFF9800);
  static const Color gradientEnd = Color(0xFFFF6D00);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [gradientStart, gradientEnd],
  );

  // ==========================================
  // Neutral Colors
  // ==========================================
  static const Color white = Color(0xFFFFFFFF);
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray850 =
      Color(0xFF2C2C2C); // Added for Dark Cards/Borders
  static const Color gray900 = Color(0xFF212121);
  static const Color black = Color(0xFF121212);

  // ==========================================
  // Semantic Colors
  // ==========================================
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFFACC15);
  static const Color danger = Color(0xFFEF4444);
  static const Color error =
      Color(0xFFDC2626); // Added (Alias for danger/error states)
  static const Color info = Color(0xFF3B82F6);

  // ==========================================
  // Adaptive Backgrounds & Surfaces
  // ==========================================
  // Light Mode Surfaces
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F8FA);
  static const Color surfaceElevatedLight = Color(0xFFFFFFFF);

  // Dark Mode Surfaces
  static const Color backgroundDark = Color(0xFF0E1116);
  static const Color surfaceDark = Color(0xFF1A1D24);
  static const Color surfaceElevatedDark = Color(0xFF232730);

  // Divider & Border Compatibility
  static const Color divider = gray200;
  static const Color dividerDark = gray800;
}
