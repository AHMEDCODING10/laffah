import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../error/exceptions.dart';

class LaravelErrorInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage;

  LaravelErrorInterceptor(this.secureStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await secureStorage.delete(key: 'sanctum_token');
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException('جلسة العمل انتهت، يرجى إعادة تسجيل الدخول'),
          response: err.response,
          type: err.type,
        ),
      );
    } else if (err.response?.statusCode == 422) {
      final data = err.response?.data;
      Map<String, List<String>> fieldErrors = {};
      if (data != null && data is Map && data['errors'] is Map) {
        (data['errors'] as Map<String, dynamic>).forEach((key, value) {
          if (value is List) {
            fieldErrors[key] = value.map((e) => e.toString()).toList();
          } else if (value != null) {
            fieldErrors[key] = [value.toString()];
          }
        });
      }
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: LaravelValidationException(
            message: data is Map && data['message'] != null ? data['message'].toString() : 'بيانات غير صالحة',
            fieldErrors: fieldErrors,
          ),
          response: err.response,
          type: err.type,
        ),
      );
    }
    return handler.next(err);
  }
}
