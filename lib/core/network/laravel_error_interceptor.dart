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
      String message = 'بيانات غير صالحة';

      if (data != null && data is Map) {
        if (data['errors'] is Map) {
          (data['errors'] as Map<String, dynamic>).forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              fieldErrors[key] = value.map((e) => e.toString()).toList();
            } else if (value != null) {
              fieldErrors[key] = [value.toString()];
            }
          });
        }
        
        if (fieldErrors.isNotEmpty) {
          final firstList = fieldErrors.values.first;
          if (firstList.isNotEmpty) {
            message = firstList.first;
          }
        } else if (data['message'] != null) {
          message = data['message'].toString();
        }
      }

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: LaravelValidationException(
            message: message,
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
