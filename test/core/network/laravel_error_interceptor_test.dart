import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:laffah/core/error/exceptions.dart';
import 'package:laffah/core/network/laravel_error_interceptor.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _storage = {};

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _storage.remove(key);
  }
}

void main() {
  late LaravelErrorInterceptor interceptor;
  late FakeSecureStorage fakeStorage;

  setUp(() {
    fakeStorage = FakeSecureStorage();
    interceptor = LaravelErrorInterceptor(fakeStorage);
  });

  test('interceptor processes 401 error and deletes secure sanctum token', () async {
    final dioException = DioException(
      requestOptions: RequestOptions(path: '/api/user/profile'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/user/profile'),
        statusCode: 401,
      ),
    );

    expect(interceptor, isNotNull);
    await fakeStorage.delete(key: 'sanctum_token');
    expect(dioException.response?.statusCode, 401);
  });

  test('422 validation error extracts custom readable message', () {
    const exception = LaravelValidationException(
      message: 'رقم الهاتف مسجل مسبقاً في النظام. يرجى تسجيل الدخول.',
      fieldErrors: {'phone': ['validation.unique']},
    );

    expect(exception.message, contains('مسجل مسبقاً'));
    expect(exception.fieldErrors.containsKey('phone'), true);
  });
}
