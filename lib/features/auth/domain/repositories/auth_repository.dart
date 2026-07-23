import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, String>> sendOtp(String phone);
  Future<Either<Failure, UserEntity>> verifyOtp(String phone, String code);
  Future<Either<Failure, void>> logout();
}
