import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'l10n/app_localizations.dart';
import 'core/bloc/locale/locale_bloc.dart';
import 'core/bloc/locale/locale_state.dart';
import 'core/theme/theme_controller.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/ride/presentation/bloc/ride_bloc.dart';
import 'features/captain/presentation/bloc/core/captain_bloc.dart';
import 'features/captain/presentation/bloc/core/captain_event.dart';
import 'features/passenger/presentation/bloc/wallet_bloc.dart';
import 'features/passenger/presentation/bloc/wallet_event.dart';
import 'core/widgets/offline_warning_wrapper.dart';

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
            return BlocListener<AuthBloc, AuthState>(
              listener: (context, state) {
                if (state is AuthInitial) {
                  context.read<RideBloc>().add(const ResetRideState());
                  context.read<CaptainBloc>().add(const ResetCaptainState());
                  context.read<WalletBloc>().add(const ResetWalletEvent());
                }
              },
              child: MaterialApp.router(
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


              // Global builder: enforce Directionality and strict text scaling clamp (1.0)
              builder: (BuildContext context, Widget? child) {
                return MediaQuery.withClampedTextScaling(
                  minScaleFactor: 1.0,
                  maxScaleFactor: 1.0,
                  child: Directionality(
                    // Automatically adjust direction based on the current locale
                    textDirection: localeState.locale.languageCode == 'ar'
                        ? TextDirection.rtl
                        : TextDirection.ltr,
                    child: OfflineWarningWrapper(
                      child: child ?? const SizedBox.shrink(),
                    ),
                  ),
                );
              },
            ));
          },
        );
      },
    );
  }
}
