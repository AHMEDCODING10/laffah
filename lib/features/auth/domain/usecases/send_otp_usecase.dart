import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, String>> call(String phone) async {
    // Basic phone validation
    if (phone.isEmpty || phone.length < 7) {
      return const Left(ValidationFailure('الرجاء إدخال رقم هاتف صحيح'));
    }
    return await repository.sendOtp(phone);
  }
}
