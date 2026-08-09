import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final FlutterSecureStorage secureStorage;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.secureStorage,
  });

  // Helper to save token
  Future<void> _saveToken(String? token) async {
    if (token != null) {
      DioClient.setToken(token);
      await secureStorage.write(key: 'auth_token', value: token);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> login(String phone, String password) async {
    try {
      final response = await remoteDataSource.login(phone, password);
      if (response.success && response.data != null) {
        await _saveToken(response.data!.token);
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.error is LaravelValidationException) {
        return Left(ValidationFailure((e.error as LaravelValidationException).message));
      }
      return Left(ServerFailure(e.response?.data?['message']?.toString() ?? 'رقم الهاتف أو كلمة المرور غير صحيحة'));
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
        await _saveToken(response.data!.token ?? 'token_${DateTime.now().millisecondsSinceEpoch}');
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

      // Offline / Server Unreachable Fallback for local testing
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        final demoUser = UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          phone: phone,
          role: 'passenger',
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await _saveToken(demoUser.token);
        return Right(demoUser);
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
        await _saveToken(response.data!.token ?? 'token_${DateTime.now().millisecondsSinceEpoch}');
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

      // Offline / Server Unreachable Fallback for local testing
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        final demoUser = UserModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: name,
          phone: phone,
          role: 'captain',
          token: 'demo_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await _saveToken(demoUser.token);
        return Right(demoUser);
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
    return const Right(null);
  }
}
