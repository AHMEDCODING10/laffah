import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_data_source.dart';
import '../models/saved_place_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;
  ProfileEntity? _cachedProfile;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileEntity>> getProfile() async {
    try {
      final response = await remoteDataSource.getProfile();
      if (response.success && response.data != null) {
        _cachedProfile = response.data!;
        return Right(response.data!);
      } else {
        if (_cachedProfile != null) return Right(_cachedProfile!);
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (_cachedProfile != null) return Right(_cachedProfile!);
      return Left(ServerFailure('تعذر جلب بيانات الملف الشخصي: $e'));
    } catch (e) {
      if (_cachedProfile != null) return Right(_cachedProfile!);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,
  }) async {
    try {
      final response = await remoteDataSource.updateProfile(
        name: name,
        phone: phone,
        email: email,
        vehicleType: vehicleType,
        vehicleModel: vehicleModel,
        plateNumber: plateNumber,
        vehicleColor: vehicleColor,
      );
      if (response.success && response.data != null) {
        _cachedProfile = response.data!;
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('تعذر تحديث الملف الشخصي: $e'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SavedPlaceEntity>>> getSavedPlaces() async {
    try {
      final response = await remoteDataSource.getSavedPlaces();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('تعذر جلب الأماكن المحفوظة: $e'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SavedPlaceEntity>> addSavedPlace(
      SavedPlaceEntity place) async {
    try {
      final model = SavedPlaceModel(
        id: place.id,
        name: place.name,
        address: place.address,
        lat: place.lat,
        lng: place.lng,
        type: place.type,
      );
      final response = await remoteDataSource.addSavedPlace(model);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      return Left(ServerFailure('تعذر إضافة المكان المحفوظ: $e'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
