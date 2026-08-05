import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/ride_entity.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_data_source.dart';
import '../../../../core/network/websocket_client.dart';
import '../models/ride_model.dart';

class RideRepositoryImpl implements RideRepository {
  final RideRemoteDataSource remoteDataSource;
  final LaffahWebSocketClient webSocketClient;

  RideRepositoryImpl({
    required this.remoteDataSource,
    required this.webSocketClient,
  });

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
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory() async {
    try {
      final trips = await remoteDataSource.getTripHistory();
      return Right(trips);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        return const Left(ServerFailure('انتهت جلسة الدخول، يرجى تسجيل الدخول مجدداً'));
      }
      return const Left(ServerFailure('تعذّر تحميل سجل الرحلات. تحقق من اتصالك بالإنترنت'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId) {
    // 1. Send connection request to the specific ride channel
    webSocketClient.connect('trip.$rideId');

    // 2. Map the incoming WebSocket events to Either<Failure, RideEntity>
    return webSocketClient.events.map((eventData) {
      try {
        // Assume Laravel broadcasts a 'RideStatusUpdated' event with the ride data
        if (eventData['event'] == 'RideStatusUpdated') {
          final rideModel = RideModel.fromJson(eventData['data']);
          return Right<Failure, RideEntity>(rideModel);
        }
        // For other events, we can return a default or ignore (though stream map requires a return)
        // For now, if we can't parse, we return a ServerFailure. But usually we filter first.
        return const Left<Failure, RideEntity>(ServerFailure('حدث غير معروف'));
      } catch (e) {
        return Left<Failure, RideEntity>(ServerFailure(e.toString()));
      }
    }).where((either) {
      // Filter out 'unknown event' failures so we don't pollute the UI
      return either.fold((f) => f.message != 'حدث غير معروف', (r) => true);
    });
  }
}
