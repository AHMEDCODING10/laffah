import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized, type-safe configuration provider for Laffah application environment variables.
class AppEnv {
  // Prevent instantiation
  AppEnv._();

  /// Backend API Base URL
  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:8000/api';

  /// MapTiler Vector & Raster Tile API Key
  static String get mapTilerKey => dotenv.env['MAPTILER_API_KEY'] ?? '';

  /// Pusher / Reverb App ID
  static String get pusherAppId => dotenv.env['PUSHER_APP_ID'] ?? '';

  /// Pusher / Reverb App Key
  static String get pusherAppKey => dotenv.env['PUSHER_APP_KEY'] ?? '';

  /// Pusher / Reverb App Secret
  static String get pusherAppSecret => dotenv.env['PUSHER_APP_SECRET'] ?? '';

  /// Pusher Cluster (default: eu)
  static String get pusherAppCluster =>
      dotenv.env['PUSHER_APP_CLUSTER'] ?? 'eu';

  /// LocationIQ Reverse Geocoding Key
  static String get locationIqKey => dotenv.env['LOCATION_IQ_KEY'] ?? '';
}
