import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/ride/presentation/bloc/ride_bloc.dart';
import 'features/captain/presentation/bloc/core/captain_bloc.dart';
import 'features/parcel/presentation/bloc/parcel_bloc.dart';
import 'features/profile/presentation/bloc/profile_bloc.dart';
import 'features/passenger/presentation/bloc/wallet_bloc.dart';
import 'core/bloc/locale/locale_bloc.dart';
import 'core/bloc/locale/locale_event.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/theme/theme_controller.dart';
import 'core/di/injection_container.dart' as di;
import 'core/network/dio_client.dart';
import 'core/router/app_router.dart';

/// Laffah Application Entry Point
/// ===============================
/// منصة لَفَّة — حصرياً للدراجات النارية (المواتير)
/// المشاوير السريعة والتوصيل الفوري للطرود في صنعاء، اليمن
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 0. Load Environment Variables
  await dotenv.load(fileName: ".env");

  // 1. Initialize ThemeController (Default is Light Mode)
  await ThemeController.instance.init();

  // 2. Initialize Dependency Injection with safe log tracking
  debugPrint("🚀 [Laffah] Initializing Dependency Injection...");
  await di.init();
  debugPrint("✅ [Laffah] Dependency Injection Ready!");

  // 3. Global Security Listener for 401 Unauthorized
  NetworkEventBus.authEvents.listen((event) {
    if (event == 'UNAUTHENTICATED') {
      debugPrint(
          "🔒 [Laffah Security] 401 Unauthorized detected. Purging session and redirecting to Auth Landing.");
      AppRouter.router.go(LaffahRoutes.authLanding);
    }
  });

  // System UI customization is mobile-only
  if (!kIsWeb) {
    // Lock to portrait — essential for safe single-handed motorcycle operation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Configure system UI chrome to blend seamlessly with the Laffah dark theme
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF0E1116),
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  debugPrint("🎬 [Laffah] Running App...");

  runApp(
    MultiBlocProvider(
      providers: [
        // Auth BLoC — lazy set to true to prevent blocking app startup on web
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          lazy: true,
        ),
        // Ride BLoC — manages passenger ride request lifecycle
        BlocProvider<RideBloc>(
          create: (_) => di.sl<RideBloc>(),
          lazy: true,
        ),
        // Captain BLoC — manages captain online/offline and trip states
        BlocProvider<CaptainBloc>(
          create: (_) => di.sl<CaptainBloc>(),
          lazy: true,
        ),
        BlocProvider<ParcelBloc>(
          create: (_) => di.sl<ParcelBloc>(),
          lazy: true,
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => di.sl<ProfileBloc>(),
          lazy: true,
        ),
        BlocProvider<WalletBloc>(
          create: (_) => di.sl<WalletBloc>(),
          lazy: true,
        ),
        BlocProvider<LocaleBloc>(
          create: (_) => di.sl<LocaleBloc>()..add(LoadSavedLocale()),
          lazy: false,
        ),
      ],
      child: const LaffahApp(),
    ),
  );
}
