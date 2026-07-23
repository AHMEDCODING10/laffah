import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call(String phone, String code) async {
    if (code.length != 4) {
      return const Left(ValidationFailure('رمز التحقق يجب أن يكون 4 أرقام'));
    }
    return await repository.verifyOtp(phone, code);
  }
}
