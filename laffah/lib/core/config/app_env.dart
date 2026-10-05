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

  static String _getEnv(String key, [String defaultValue = '']) {
    try {
      if (dotenv.isInitialized) {
        return dotenv.env[key] ?? defaultValue;
      }
    } catch (_) {}
    return defaultValue;
  }

  /// MapTiler Vector & Raster Tile API Key
  static String get mapTilerKey => _getEnv('MAPTILER_API_KEY');

  /// Pusher / Reverb App ID
  static String get pusherAppId => _getEnv('PUSHER_APP_ID');

  /// Pusher / Reverb App Key
  static String get pusherAppKey => _getEnv('PUSHER_APP_KEY');

  /// Pusher Cluster (default: eu)
  static String get pusherAppCluster => _getEnv('PUSHER_APP_CLUSTER', 'eu');

  /// LocationIQ Reverse Geocoding Key
  static String get locationIqKey => _getEnv('LOCATION_IQ_KEY');

  /// Mapbox Public Access Token
  static String get mapboxToken => _getEnv('MAPBOX_ACCESS_TOKEN');

  /// Use Reverb instead of Pusher Cloud?
  static bool get useReverb => _getEnv('USE_REVERB') == 'true';
}
