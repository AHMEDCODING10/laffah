import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  @override
  Future<Either<Failure, String>> sendOtp(String phone) async {
    try {
      final response = await remoteDataSource.sendOtp(phone);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        // Handle Laravel validation errors specifically if needed
        return const Left(ValidationFailure('رقم الهاتف غير صالح'));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String phone, String code) async {
    try {
      final response = await remoteDataSource.verifyOtp(phone, code);
      if (response.success && response.data != null) {
        final userModel = response.data!;
        // Save token to secure storage
        if (userModel.token != null) {
          await secureStorage.write(key: 'sanctum_token', value: userModel.token);
        }
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('بيانات غير صحيحة، تأكد من الرمز المدخل.'));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    await secureStorage.delete(key: 'sanctum_token');
    return const Right(null);
  }
}
