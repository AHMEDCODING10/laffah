import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ThemeController — Manages dynamic Light/Dark theme switching for Laffah.
/// Default ThemeMode is set to ThemeMode.light as requested.
class ThemeController extends ValueNotifier<ThemeMode> {
  static final ThemeController instance = ThemeController._();

  ThemeController._() : super(ThemeMode.light);

  static const String _key = 'app_theme_mode';

  /// Initializes saved theme mode from SharedPreferences, defaulting to Light Mode.
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_key);
      if (savedTheme == 'dark') {
        value = ThemeMode.dark;
      } else {
        value = ThemeMode.light;
      }
    } catch (_) {
      value = ThemeMode.light;
    }
  }

  bool get isDarkMode => value == ThemeMode.dark;

  /// Toggles theme mode and saves preference.
  Future<void> toggleTheme(bool isDark) async {
    value = isDark ? ThemeMode.dark : ThemeMode.light;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, isDark ? 'dark' : 'light');
    } catch (_) {}
  }
}
