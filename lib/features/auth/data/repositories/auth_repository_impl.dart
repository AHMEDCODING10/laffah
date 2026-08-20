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

  // Helper to save token and user role
  Future<void> _saveSession(String? token, String? role) async {
    if (token != null && token.isNotEmpty) {
      DioClient.setToken(token);
      await secureStorage.write(key: 'auth_token', value: token);
      if (role != null && role.isNotEmpty) {
        await secureStorage.write(key: 'user_role', value: role);
      }
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(
      String phone, String password) async {
    try {
      final response = await remoteDataSource.login(phone, password);
      if (response.success && response.data != null) {
        await _saveSession(response.data!.token, response.data!.role);
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        return Left(
            ValidationFailure((e.error as LaravelValidationException).message));
      }
      return Left(ServerFailure(
          e.response?.data?['message']?.toString() ?? 'Invalid credentials'));
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
        await _saveSession(
            response.data!.token ?? 'token_${DateTime.now().millisecondsSinceEpoch}',
            response.data!.role.isNotEmpty ? response.data!.role : 'passenger');
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message.isNotEmpty ? response.message : 'فشل إنشاء حساب الراكب'));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      if (e.response?.data != null && e.response?.data is Map) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(e.response!.data as Map);
        final String? msg = body['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          return Left(ServerFailure(msg));
        }
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
        await _saveSession(
            response.data!.token ?? 'token_${DateTime.now().millisecondsSinceEpoch}',
            response.data!.role.isNotEmpty ? response.data!.role : 'captain');
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message.isNotEmpty ? response.message : 'فشل إنشاء حساب الكابتن'));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        final exception = e.error as LaravelValidationException;
        return Left(ValidationFailure(exception.message));
      }
      if (e.response?.data != null && e.response?.data is Map) {
        final Map<String, dynamic> body = Map<String, dynamic>.from(e.response!.data as Map);
        final String? msg = body['message']?.toString();
        if (msg != null && msg.isNotEmpty) {
          return Left(ServerFailure(msg));
        }
      }

      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Call backend to invalidate the JWT token
      await remoteDataSource.logoutFromServer();
    } catch (_) {
      // Even if backend call fails, clear local storage
    }
    DioClient.setToken(null);
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'user_role');
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final response = await remoteDataSource.deleteAccount();
      if (response.success) {
        DioClient.setToken(null);
        await secureStorage.delete(key: 'auth_token');
        await secureStorage.delete(key: 'user_role');
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure(
          e.response?.data?['message']?.toString() ?? 'فشل حذف الحساب'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword(String phone) async {
    try {
      final response = await remoteDataSource.forgotPassword(phone);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return const Left(ServerFailure('Phone number not registered'));
      }
      return Left(ServerFailure(
          e.response?.data?['message']?.toString() ?? 'Error sending code'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> verifyResetCode(
      String phone, String code) async {
    try {
      final response = await remoteDataSource.verifyResetCode(phone, code);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ServerFailure('Invalid code'));
      }
      return Left(ServerFailure(
          e.response?.data?['message']?.toString() ?? 'Error verifying code'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword(
      String phone, String code, String newPassword) async {
    try {
      final response =
          await remoteDataSource.resetPassword(phone, code, newPassword);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return const Left(ServerFailure('Invalid data'));
      }
      return Left(ServerFailure(e.response?.data?['message']?.toString() ??
          'Error setting password'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
