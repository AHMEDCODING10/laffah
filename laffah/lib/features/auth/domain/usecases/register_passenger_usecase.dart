import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class RegisterPassengerUseCase {
  final AuthRepository repository;

  RegisterPassengerUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String password,
  }) async {
    if (phone.isEmpty || name.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Missing data'));
    }
    return await repository.registerPassenger(
      name: name,
      phone: phone,
      password: password,
    );
  }
}
