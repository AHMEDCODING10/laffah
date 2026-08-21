import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure(
    super.message, {
    this.fieldErrors = const {},
  });

  /// 🎯 استخراج أول رسالة خطأ لحقل معين لعرضها تحت الـ TextFormField مباشرة
  String? getFirstErrorFor(String fieldName) {
    final errors = fieldErrors[fieldName];
    if (errors != null && errors.isNotEmpty) {
      return errors.first;
    }
    return null;
  }

  /// التحقق ما إذا كان حقل معين يحتوي على أخطاء
  bool hasErrorFor(String fieldName) {
    return fieldErrors.containsKey(fieldName) &&
        fieldErrors[fieldName]!.isNotEmpty;
  }

  /// الحصول على كافة أخطاء حقل معين
  List<String> getAllErrorsFor(String fieldName) {
    return fieldErrors[fieldName] ?? [];
  }

  @override
  List<Object?> get props => [message, fieldErrors];
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'انتهت جلسة الاستخدام، يرجى إعادة تسجيل الدخول',
  ]);
}
