import 'package:dio/dio.dart';
import '../storage/secure_storage_service.dart';
import '../error/exceptions.dart';

class LaravelErrorInterceptor extends Interceptor {
  final SecureStorageService secureStorage;

  LaravelErrorInterceptor(this.secureStorage);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      await secureStorage.clearToken();
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const UnauthorizedException(
              'جلسة العمل انتهت، يرجى إعادة تسجيل الدخول'),
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
      String errorMessage = data is Map && data['message'] != null
          ? data['message'].toString()
          : message;

      if (fieldErrors.isNotEmpty) {
        final firstError = fieldErrors.values.first.first;
        if (firstError == 'validation.unique' ||
            firstError.contains('unique')) {
          errorMessage = 'رقم الهاتف مسجل مسبقاً في النظام. يرجى تسجيل الدخول.';
        } else if (firstError.contains('validation.')) {
          errorMessage = 'يرجى التحقق من البيانات المدخلة';
        } else {
          errorMessage = firstError;
        }
      }

      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: LaravelValidationException(
            message: errorMessage,
            fieldErrors: fieldErrors,
          ),
          response: err.response,
          type: err.type,
        ),
      );
    } else if (err.response?.statusCode == 404) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const ServerException('الخدمة المطلوبة غير متوفرة حالياً (404)'),
          response: err.response,
          type: err.type,
        ),
      );
    } else if (err.response?.statusCode == 500) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const ServerException('حدث خطأ داخلي في الخادم (500)، يرجى المحاولة لاحقاً'),
          response: err.response,
          type: err.type,
        ),
      );
    } else if (err.type == DioExceptionType.connectionTimeout || err.type == DioExceptionType.connectionError) {
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: const ServerException('تعذر الاتصال بالخادم، يرجى التحقق من الاتصال بالشبكة'),
          response: err.response,
          type: err.type,
        ),
      );
    }
    return handler.next(err);
  }
}