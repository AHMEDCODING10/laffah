import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/captain_status_entity.dart';
import '../../domain/repositories/captain_repository.dart';
import '../datasources/captain_remote_data_source.dart';

class CaptainRepositoryImpl implements CaptainRepository {
  final CaptainRemoteDataSource remoteDataSource;

  CaptainRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CaptainStatusEntity>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    try {
      final response = await remoteDataSource.toggleOnlineStatus(
        isOnline: isOnline,
        lat: lat,
        lng: lng,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم لتحديث الحالة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  }) async {
    try {
      final response = await remoteDataSource.respondToTripRequest(
        tripId: tripId,
        accept: accept,
      );

      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء الاستجابة لطلب الرحلة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
