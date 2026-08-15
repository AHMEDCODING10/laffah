import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// RetryInterceptor — Automatically retries failed HTTP requests due to intermittent
/// network drops or server timeouts on unstable mobile connections (e.g. Yemeni 3G/4G).
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final List<Duration> retryDelays;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelays = const [
      Duration(milliseconds: 1000),
      Duration(milliseconds: 2000),
      Duration(milliseconds: 4000),
    ],
  });

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final extra = err.requestOptions.extra;
    final int retryCount = (extra['retry_count'] as int?) ?? 0;

    if (_shouldRetry(err) && retryCount < maxRetries) {
      final delay = retryCount < retryDelays.length
          ? retryDelays[retryCount]
          : retryDelays.last;

      debugPrint(
          '🔄 [Network Resilience] Retrying request (${retryCount + 1}/$maxRetries) to: ${err.requestOptions.path} after ${delay.inMilliseconds}ms');

      await Future.delayed(delay);

      try {
        final newOptions = Options(
          method: err.requestOptions.method,
          headers: err.requestOptions.headers,
          contentType: err.requestOptions.contentType,
          responseType: err.requestOptions.responseType,
          extra: Map<String, dynamic>.from(err.requestOptions.extra)
            ..['retry_count'] = retryCount + 1,
        );

        final response = await dio.request(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: newOptions,
        );

        return handler.resolve(response);
      } on DioException catch (retryError) {
        return handler.reject(retryError);
      } catch (e) {
        return handler.reject(err);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on timeouts
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on socket or network errors
    if (err.error is SocketException || err.error is TimeoutException) {
      return true;
    }

    // Retry on temporary server errors (502, 503, 504)
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500 && statusCode <= 504) {
      return true;
    }

    return false;
  }
}
