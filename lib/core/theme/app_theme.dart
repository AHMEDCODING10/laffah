import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// Laffah Application Themes
/// Standardizes Light and Dark modes with IBM Plex Sans Arabic first.
class AppTheme {
  AppTheme._();

  static const String arabicFontFamily = 'IBM Plex Sans Arabic';
  static const String englishFontFamily = 'SF Pro Display';

  // ==========================================
  // Light Theme Definition
  // ==========================================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      fontFamily: arabicFontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary500,
        secondary: AppColors.primary600,
        surface: AppColors.surfaceLight,
        error: AppColors.danger,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.gray900,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.gray900,
        ),
        iconTheme: IconThemeData(color: AppColors.gray900),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        headlineLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        headlineMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppColors.gray900,
        ),
        titleLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.gray900,
        ),
        bodyLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray800,
        ),
        bodyMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray700,
        ),
        labelMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray600,
        ),
        bodySmall: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedLight,
        elevation: 2,
        shadowColor: AppColors.gray900.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          ),
          textStyle: const TextStyle(
            fontFamily: arabicFontFamily,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.gray600,
          fontSize: 14,
        ),
      ),
    );
  }

  // ==========================================
  // Dark Theme Definition
  // ==========================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.primary500,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      fontFamily: arabicFontFamily,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary500,
        secondary: AppColors.primary400,
        surface: AppColors.surfaceDark,
        error: AppColors.danger,
        onPrimary: AppColors.black,
        onSecondary: AppColors.black,
        onSurface: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 32.0,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 28.0,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        headlineMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 24.0,
          fontWeight: FontWeight.bold,
          color: AppColors.white,
        ),
        titleLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 20.0,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
        bodyLarge: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 18.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray200,
        ),
        bodyMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 16.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray300,
        ),
        labelMedium: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 14.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray400,
        ),
        bodySmall: TextStyle(
          fontFamily: arabicFontFamily,
          fontSize: 12.0,
          fontWeight: FontWeight.normal,
          color: AppColors.gray500,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceElevatedDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary500,
          foregroundColor: AppColors.black,
          elevation: 0,
          minimumSize: const Size(double.infinity, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          ),
          textStyle: const TextStyle(
            fontFamily: arabicFontFamily,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: const BorderSide(color: AppColors.primary500, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMDValue),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: AppColors.gray400,
          fontSize: 14,
        ),
      ),
    );
  }
}
