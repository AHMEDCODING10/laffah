import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/ride/presentation/bloc/ride_bloc.dart';
import 'features/captain/presentation/bloc/captain_bloc.dart';

import 'core/di/injection_container.dart' as di;

/// Laffah Application Entry Point
/// ===============================
/// منصة لَفَّة — حصرياً للدراجات النارية (المواتير)
/// المشاوير السريعة والتوصيل الفوري للطرود في صنعاء، اليمن
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Dependency Injection
  await di.init();

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

  runApp(
    MultiBlocProvider(
      providers: [
        // Auth BLoC — eager initialization for instant OTP flow readiness
        BlocProvider<AuthBloc>(
          create: (_) => di.sl<AuthBloc>(),
          lazy: false,
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
      ],
      child: const LaffahApp(),
    ),
  );
}
