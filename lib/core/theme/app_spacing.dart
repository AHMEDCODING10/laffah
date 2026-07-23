import 'package:flutter/widgets.dart';

/// Laffah Spacing & Layout System
/// Implements the strict grid system and Border Radius standards
class AppSpacing {
  AppSpacing._();

  // ==========================================
  // Spacing Scale (Numeric Values)
  // ==========================================
  static const double s2 = 2.0;
  static const double s4 = 4.0;
  static const double s6 = 6.0;
  static const double s8 = 8.0;
  static const double s10 = 10.0;
  static const double s12 = 12.0;
  static const double s14 = 14.0;
  static const double s16 = 16.0;
  static const double s20 = 20.0;
  static const double s24 = 24.0;
  static const double s32 = 32.0;
  static const double s40 = 40.0;
  static const double s48 = 48.0;
  static const double s64 = 64.0;
  static const double s80 = 80.0;
  static const double s96 = 96.0;

  // Pre-configured SizedBox for vertical spacing
  static const SizedBox h2 = SizedBox(height: s2);
  static const SizedBox h4 = SizedBox(height: s4);
  static const SizedBox h6 = SizedBox(height: s6);
  static const SizedBox h8 = SizedBox(height: s8);
  static const SizedBox h10 = SizedBox(height: s10);
  static const SizedBox h12 = SizedBox(height: s12);
  static const SizedBox h16 = SizedBox(height: s16);
  static const SizedBox h20 = SizedBox(height: s20);
  static const SizedBox h24 = SizedBox(height: s24);
  static const SizedBox h32 = SizedBox(height: s32);
  static const SizedBox h40 = SizedBox(height: s40);
  static const SizedBox h48 = SizedBox(height: s48);
  static const SizedBox h64 = SizedBox(height: s64);
  static const SizedBox h80 = SizedBox(height: s80);
  static const SizedBox h96 = SizedBox(height: s96);

  // Pre-configured SizedBox for horizontal spacing
  static const SizedBox w2 = SizedBox(width: s2);
  static const SizedBox w4 = SizedBox(width: s4);
  static const SizedBox w6 = SizedBox(width: s6);
  static const SizedBox w8 = SizedBox(width: s8);
  static const SizedBox w10 = SizedBox(width: s10);
  static const SizedBox w12 = SizedBox(width: s12);
  static const SizedBox w16 = SizedBox(width: s16);
  static const SizedBox w20 = SizedBox(width: s20);
  static const SizedBox w24 = SizedBox(width: s24);
  static const SizedBox w32 = SizedBox(width: s32);
  static const SizedBox w40 = SizedBox(width: s40);
  static const SizedBox w48 = SizedBox(width: s48);
  static const SizedBox w64 = SizedBox(width: s64);
  static const SizedBox w80 = SizedBox(width: s80);
  static const SizedBox w96 = SizedBox(width: s96);

  // ==========================================
  // Border Radius Constants (Numeric Values)
  // ==========================================
  static const double radiusXSValue = 8.0;
  static const double radiusSMValue = 12.0;
  static const double radiusMDValue = 16.0;
  static const double radiusLGValue = 20.0;
  static const double radiusXLValue = 28.0;
  static const double radiusBottomSheetValue = 32.0;
  static const double radiusFullValue = 999.0;

  // Short aliases for numeric values (double)
  static const double rXS = radiusXSValue;
  static const double rSM = radiusSMValue;
  static const double rMD = radiusMDValue;
  static const double rLG = radiusLGValue;
  static const double rXL = radiusXLValue;
  static const double rBS = radiusBottomSheetValue;
  static const double rFull = radiusFullValue;

  // ==========================================
  // BorderRadius Objects
  // ==========================================
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(radiusXSValue));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(radiusSMValue));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(radiusMDValue));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(radiusLGValue));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(radiusXLValue));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(radiusFullValue));

  static const BorderRadius radiusBottomSheet = BorderRadius.only(
    topLeft: Radius.circular(radiusBottomSheetValue),
    topRight: Radius.circular(radiusBottomSheetValue),
  );

  // Aliases for compatibility
  static BorderRadius get borderXS => radiusXS;
  static BorderRadius get borderSM => radiusSM;
  static BorderRadius get borderMD => radiusMD;
  static BorderRadius get borderLG => radiusLG;
  static BorderRadius get borderXL => radiusXL;
  static BorderRadius get borderBottomSheet => radiusBottomSheet;
  static BorderRadius get borderFull => radiusFull;
}

// ==========================================
// Extension for Seamless Conversion
// ==========================================
extension BorderRadiusToDouble on BorderRadius {
  /// Extract double value from BorderRadius object when passed inside BorderRadius.circular
  double get value => topLeft.x;
}