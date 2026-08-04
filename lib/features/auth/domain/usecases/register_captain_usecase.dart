import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/auth_repository.dart';
import '../entities/user_entity.dart';

class RegisterCaptainUseCase {
  final AuthRepository repository;

  RegisterCaptainUseCase(this.repository);

  Future<Either<Failure, UserEntity>> call({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleModel,
    required int vehicleYear,
    required String vehiclePlate,
  }) async {
    if (phone.isEmpty || name.isEmpty || password.isEmpty) {
      return const Left(ValidationFailure('Invalid data'));
    }
    return await repository.registerCaptain(
      name: name,
      phone: phone,
      password: password,
      vehicleType: vehicleType,
      vehicleModel: vehicleModel,
      vehicleYear: vehicleYear,
      vehiclePlate: vehiclePlate,
    );
  }
}
