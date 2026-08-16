import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String phone, String password);

  Future<Either<Failure, UserEntity>> registerPassenger({
    required String name,
    required String phone,
    required String password,
  });
  Future<Either<Failure, UserEntity>> registerCaptain({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleModel,
    required int vehicleYear,
    required String vehiclePlate,
  });
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> forgotPassword(String phone);
  Future<Either<Failure, void>> verifyResetCode(String phone, String code);
  Future<Either<Failure, void>> resetPassword(
      String phone, String code, String newPassword);
}
