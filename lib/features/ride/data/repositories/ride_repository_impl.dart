import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_data_source.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource remoteDataSource;

  RideRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, RideEntity>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    required String rideType,
    required double expectedPrice,
  }) async {
    try {
      final response = await remoteDataSource.requestRide(
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        rideType: rideType,
        expectedPrice: expectedPrice,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return const Left(ValidationFailure('بيانات الرحلة غير صالحة'));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بخوادم لفة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> cancelRide(String rideId) async {
    try {
      final response = await remoteDataSource.cancelRide(rideId);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم لإلغاء الرحلة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId) {
    return Stream<Either<Failure, RideEntity>>.periodic(const Duration(seconds: 3), (count) {
      if (count == 0) {
        return const Right<Failure, RideEntity>(RideEntity(
          id: 'LFH-1234',
          status: 'found',
          price: 1500,
          pickupLocation: '...',
          dropoffLocation: '...',
          captainName: 'أحمد صالح',
          vehicleModel: 'Honda Wave 125',
          vehiclePlate: '1234/ص',
          rating: 4.8,
        ));
      }
      return const Right<Failure, RideEntity>(RideEntity(
        id: 'LFH-1234',
        status: 'in_progress',
        price: 1500,
        pickupLocation: '...',
        dropoffLocation: '...',
        captainName: 'أحمد صالح',
        vehicleModel: 'Honda Wave 125',
        vehiclePlate: '1234/ص',
        rating: 4.8,
      ));
    }).take(2);
  }
}
