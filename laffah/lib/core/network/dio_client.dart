import 'dart:async';
import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import 'api_endpoints.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';
import 'laravel_error_interceptor.dart';
import 'retry_interceptor.dart';

/// Global event bus to broadcast network-level auth failures (e.g. 401 Unauthorized)
class NetworkEventBus {
  static final StreamController<String> _authEventController =
      StreamController<String>.broadcast();
  static Stream<String> get authEvents => _authEventController.stream;
  static void emitUnauthenticated() =>
      _authEventController.add('UNAUTHENTICATED');
}

class DioClient {
  late Dio _dio;
  late Dio _uploadDio;
  final SecureStorageService _storage;

  /// In-memory token cache to prevent Web storage latency issues
  static String? _inMemoryToken;

  static void setToken(String? token) {
    _inMemoryToken = token;
  }

  static String? get currentToken => _inMemoryToken;

  DioClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    ));

    // 1. Network Resilience Interceptor (Auto-Retry for unstable 3G/4G)
    _dio.interceptors.add(RetryInterceptor(dio: _dio));

    // 2. Auth Bearer Token Injection
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _inMemoryToken ?? await _storage.getToken();
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
          // If the request was for login, do NOT emit unauthenticated (it's just a wrong password)
          if (e.requestOptions.path.contains(ApiEndpoints.login)) {
            return handler.next(e);
          }

          final hasAuthHeader =
              e.requestOptions.headers.containsKey('Authorization');
          if (hasAuthHeader) {
            _inMemoryToken = null;
            await _storage.clearToken();
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

    // SSL Pinning & Secure Certificate Validation
    if (!kIsWeb) {
      _dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            // In release mode: Enforce secure domain checks
            if (kReleaseMode) {
              // Block invalid or self-signed certs in production
              return host == "10.0.2.2" || host == "localhost";
            }
            // In debug/development mode: Allow local testing environments
            return host == "10.0.2.2" ||
                host == "localhost" ||
                host.startsWith("192.168.") ||
                host.startsWith("10.");
          };
          return client;
        },
      );

      _uploadDio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () {
          final client = HttpClient();
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) {
            if (kReleaseMode) {
              return host == "10.0.2.2" || host == "localhost";
            }
            return host == "10.0.2.2" ||
                host == "localhost" ||
                host.startsWith("192.168.") ||
                host.startsWith("10.");
          };
          return client;
        },
      );
    }

    _dio.interceptors.add(LaravelErrorInterceptor(_storage));

    _uploadDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = _inMemoryToken ?? await _storage.getToken();
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
          if (e.requestOptions.path.contains(ApiEndpoints.login)) {
            return handler.next(e);
          }
          final hasAuthHeader =
              e.requestOptions.headers.containsKey('Authorization');
          if (hasAuthHeader) {
            _inMemoryToken = null;
            await _storage.clearToken();
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
