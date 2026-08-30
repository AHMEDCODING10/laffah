import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../network/api_endpoints.dart';

/// Centralized, type-safe configuration provider for Laffah application environment variables.
class AppEnv {
  // Prevent instantiation
  AppEnv._();

  /// Are we running in local mode (for dual-environment)? 
  /// Set to true to point to Localhost/IP, false for Production Domain.
  static const bool isLocalMode = !kReleaseMode;

  /// Backend API Base URL
  static String get apiBaseUrl => ApiEndpoints.baseUrl;

  /// MapTiler Vector & Raster Tile API Key
  static String get mapTilerKey => dotenv.env['MAPTILER_API_KEY'] ?? '';

  /// Pusher / Reverb App ID
  static String get pusherAppId => dotenv.env['PUSHER_APP_ID'] ?? '';

  /// Pusher / Reverb App Key
  static String get pusherAppKey => dotenv.env['PUSHER_APP_KEY'] ?? '';

  /// Pusher Cluster (default: eu)
  static String get pusherAppCluster =>
      dotenv.env['PUSHER_APP_CLUSTER'] ?? 'eu';

  /// LocationIQ Reverse Geocoding Key
  static String get locationIqKey => dotenv.env['LOCATION_IQ_KEY'] ?? '';

  /// Use Reverb instead of Pusher Cloud?
  static bool get useReverb => dotenv.env['USE_REVERB'] == 'true';
}
