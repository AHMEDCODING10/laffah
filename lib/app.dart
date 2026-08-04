import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

/// LaffahApp — Root Application Widget for لَفَّة
/// =================================================
/// Configures:
///  • Light Mode as default with dynamic Light/Dark theme switching
///  • Arabic (Yemen) RTL Directionality enforced at all levels
///  • GoRouter declarative navigation
///  • Text scaling disabled to prevent layout breakage on accessibility overrides
class LaffahApp extends StatelessWidget {
  const LaffahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.instance,
      builder: (context, currentThemeMode, child) {
        return MaterialApp.router(
          // App identity
          title: 'لَفَّة',
          debugShowCheckedModeBanner: false,

          // Declarative GoRouter navigation
          routerConfig: AppRouter.router,

          // Laffah Design System theming (Light Mode Default)
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,

          // Yemeni Arabic locale — primary market
          locale: const Locale('ar', 'YE'),
          supportedLocales: const [
            Locale('ar', 'YE'),
            Locale('ar', 'SA'),
            Locale('ar'),
            Locale('en'),
          ],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          // Global builder: enforce RTL + disable text scaling
          builder: (BuildContext context, Widget? child) {
            return MediaQuery.withClampedTextScaling(
              minScaleFactor: 1.0,
              maxScaleFactor: 1.3,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },
        );
      },
    );
  }
}
