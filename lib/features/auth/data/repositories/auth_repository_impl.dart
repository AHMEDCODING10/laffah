import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
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
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> verifyOtp(String phone, String code, {String role = 'passenger'}) async {
    try {
      final response = await remoteDataSource.verifyOtp(phone, code, role: role);
      if (response.success && response.data != null) {
        final userModel = response.data!;
        // Save token to secure storage & in-memory cache
        if (userModel.token != null) {
          DioClient.setToken(userModel.token);
          await secureStorage.write(key: 'sanctum_token', value: userModel.token);
        }
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerPassenger({
    required String name,
    required String phone,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.registerPassenger({
        'name': name,
        'phone': phone,
        'password': password,
      });
      if (response.success && response.data != null) {
        final userModel = response.data!;
        if (userModel.token != null) {
          DioClient.setToken(userModel.token);
          await secureStorage.write(key: 'sanctum_token', value: userModel.token);
        }
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerCaptain({
    required String name,
    required String phone,
    required String password,
    required String vehicleType,
    required String vehicleModel,
    required int vehicleYear,
    required String vehiclePlate,
  }) async {
    try {
      final response = await remoteDataSource.registerCaptain({
        'name': name,
        'phone': phone,
        'password': password,
        'vehicle_type': vehicleType,
        'vehicle_model': vehicleModel,
        'vehicle_year': vehicleYear,
        'vehicle_plate': vehiclePlate,
        'plate_number': vehiclePlate,
      });
      if (response.success && response.data != null) {
        final userModel = response.data!;
        if (userModel.token != null) {
          DioClient.setToken(userModel.token);
          await secureStorage.write(key: 'sanctum_token', value: userModel.token);
        }
        return Right(userModel);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    DioClient.setToken(null);
    await secureStorage.delete(key: 'sanctum_token');
    return const Right(null);
  }
}
