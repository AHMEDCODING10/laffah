import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';
import 'laravel_error_interceptor.dart';

/// Global event bus to broadcast network-level auth failures (e.g. 401 Unauthorized)
class NetworkEventBus {
  static final StreamController<String> _authEventController = StreamController<String>.broadcast();
  static Stream<String> get authEvents => _authEventController.stream;
  static void emitUnauthenticated() => _authEventController.add('UNAUTHENTICATED');
}

class DioClient {
  late Dio _dio;
  late Dio _uploadDio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// In-memory token cache to prevent Web storage latency issues
  static String? _inMemoryToken;

  static void setToken(String? token) {
    _inMemoryToken = token;
  }

  static String? get currentToken => _inMemoryToken;

  DioClient() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _inMemoryToken ?? await _storage.read(key: 'sanctum_token');
        if (token != null && token.isNotEmpty) {
          _inMemoryToken = token;
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    // Global 401 Unauthorized Interceptor (Token Refresh Lifecycle)
    _dio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          // Only purge if an authorization header was actually sent
          // This prevents accidental logouts due to storage latency on startup
          final hasAuthHeader = e.requestOptions.headers.containsKey('Authorization');
          if (hasAuthHeader) {
            _inMemoryToken = null;
            await _storage.delete(key: 'sanctum_token');
            NetworkEventBus.emitUnauthenticated();
          }
        }
        return handler.next(e);
      },
    ));

    // Secondary Dio instance dedicated to large payload uploads (e.g., Documents)
    _uploadDio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60), // 60 seconds for slow 3G
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
      },
    ));

    // SSL Pinning Implementation
    if (!kIsWeb) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) {
            // TODO: Enable certificate pinning before production release.
            // Real SHA-1/SHA-256 hash example:
            // 'A1:B2:C3:D4:E5:F6:77:88:99:00:AA:BB:CC:DD:EE:FF:11:22:33:44'
            // Compare with: cert.sha1.toString()
            return true; // Temporarily allow all certs during development
          };
          return client;
        },
      );
      
      _uploadDio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
          return client;
        },
      );
    }

    _dio.interceptors.add(LaravelErrorInterceptor(_storage));

    _uploadDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _inMemoryToken ?? await _storage.read(key: 'sanctum_token');
        if (token != null && token.isNotEmpty) {
          _inMemoryToken = token;
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));

    _uploadDio.interceptors.add(InterceptorsWrapper(
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final hasAuthHeader = e.requestOptions.headers.containsKey('Authorization');
          if (hasAuthHeader) {
            _inMemoryToken = null;
            await _storage.delete(key: 'sanctum_token');
            NetworkEventBus.emitUnauthenticated();
          }
        }
        return handler.next(e);
      },
    ));

    _uploadDio.interceptors.add(LaravelErrorInterceptor(_storage));
  }

  Dio get dio => _dio;
  Dio get uploadDio => _uploadDio;
}
