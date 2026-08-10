import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
import 'core/bloc/locale/locale_bloc.dart';
import 'core/bloc/locale/locale_state.dart';
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
        return BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) {
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

              // Dynamic locale management
              locale: localeState.locale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,

              // Global builder: enforce Directionality and text scaling
              builder: (BuildContext context, Widget? child) {
                return MediaQuery.withClampedTextScaling(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.3,
                  child: Directionality(
                    // Automatically adjust direction based on the current locale
                    textDirection: localeState.locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: child ?? const SizedBox.shrink(),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
