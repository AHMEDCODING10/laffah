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
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String rideType,
    required double expectedPrice,
    List<Map<String, dynamic>>? stops,
    int? promoCodeId,
    bool isScheduled = false,
    DateTime? scheduledTime,
  }) async {
    try {
      final response = await remoteDataSource.requestRide(
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropoffLatitude: dropoffLatitude,
        dropoffLongitude: dropoffLongitude,
        rideType: rideType,
        expectedPrice: expectedPrice,
        stops: stops,
        promoCodeId: promoCodeId,
        isScheduled: isScheduled,
        scheduledTime: scheduledTime,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
            ? e.response?.data['message'].toString()
            : 'بيانات الرحلة غير صالحة';
        return Left(ValidationFailure(errorMsg!));
      }
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بخوادم لفة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, RideEntity>> trackRide(String rideId) async {
    try {
      final response = await remoteDataSource.trackRide(rideId);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
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
        return const Right(null);
      }
    } on DioException catch (_) {
      return const Left(
          ServerFailure('حدث خطأ أثناء الاتصال بالخادم لإلغاء الرحلة'));
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
        return const Left(
            ServerFailure('انتهت جلسة الدخول، يرجى تسجيل الدخول مجدداً'));
      }
      return const Left(
          ServerFailure('تعذّر تحميل سجل الرحلات. تحقق من اتصالك بالإنترنت'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rateTrip({
    required String tripId,
    required double rating,
    String? review,
  }) async {
    try {
      final response = await remoteDataSource.rateTrip(
        tripId: tripId,
        rating: rating,
        review: review,
      );
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'فشل إرسال التقييم للرحلة';
      return Left(ServerFailure(errorMsg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTrip(String tripId) async {
    try {
      await remoteDataSource.deleteTrip(tripId);
      return const Right(null);
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? 'فشل حذف الرحلة من السجل';
      return Left(ServerFailure(errorMsg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId) {
    webSocketClient.connect('trip.$rideId');

    return webSocketClient.events.map((eventData) {
      try {
        if (eventData['event'] == 'RideStatusUpdated') {
          final rideModel = RideModel.fromJson(eventData['data']);
          return Right<Failure, RideEntity>(rideModel);
        }
        return const Left<Failure, RideEntity>(ServerFailure('حدث غير معروف'));
      } catch (e) {
        return Left<Failure, RideEntity>(ServerFailure(e.toString()));
      }
    }).where((either) {
      return either.fold((f) => f.message != 'حدث غير معروف', (r) => true);
    });
  }
}
