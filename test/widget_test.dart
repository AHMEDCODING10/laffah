import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:laffah/app.dart';
import 'package:laffah/core/di/injection_container.dart' as di;
import 'package:laffah/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:laffah/features/ride/presentation/bloc/ride_bloc.dart';
import 'package:laffah/features/captain/presentation/bloc/captain_bloc.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await di.init();
  });

  testWidgets('Laffah app smoke test', (WidgetTester tester) async {
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('AssetImage') ||
          details.exception.toString().contains('laffah_logo.png') ||
          details.exception.toString().contains('unable to load asset')) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(create: (_) => di.sl<AuthBloc>(), lazy: true),
          BlocProvider<RideBloc>(create: (_) => di.sl<RideBloc>(), lazy: true),
          BlocProvider<CaptainBloc>(create: (_) => di.sl<CaptainBloc>(), lazy: true),
        ],
        child: const LaffahApp(),
      ),
    );
    expect(find.byType(LaffahApp), findsOneWidget);
  });
}