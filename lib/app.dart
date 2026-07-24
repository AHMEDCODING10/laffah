import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// LaffahApp — Root Application Widget for لَفَّة
/// =================================================
/// Configures:
///  • Dark-first Charcoal/Orange theming (Laffah Design System v2.0)
///  • Arabic (Yemen) RTL Directionality enforced at all levels
///  • GoRouter declarative navigation
///  • Text scaling disabled to prevent layout breakage on accessibility overrides
class LaffahApp extends StatelessWidget {
  const LaffahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // App identity
      title: 'لَفَّة',
      debugShowCheckedModeBanner: false,

      // Declarative GoRouter navigation
      routerConfig: AppRouter.router,

      // Laffah Design System theming
      // Dark mode is the primary and default Laffah experience
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

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
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            // Prevent layout overflow when system font size is increased
            textScaler: TextScaler.noScaling,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
