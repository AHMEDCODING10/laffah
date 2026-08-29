class ServerException implements Exception {
  final String message;
  const ServerException([this.message = 'حدث خطأ في الخادم']);

  @override
  String toString() => message;
}

class CacheException implements Exception {
  final String message;
  const CacheException([this.message = 'حدث خطأ في الذاكرة المؤقتة']);

  @override
  String toString() => message;
}

class UnauthorizedException implements Exception {
  final String message;
  const UnauthorizedException(
      [this.message = 'انتهت جلسة الاستخدام، يرجى إعادة تسجيل الدخول']);

  @override
  String toString() => message;
}

class LaravelValidationException implements Exception {
  final String message;
  final Map<String, List<String>> fieldErrors;

  const LaravelValidationException({
    required this.message,
    this.fieldErrors = const {},
  });

  @override
  String toString() => message;
}
