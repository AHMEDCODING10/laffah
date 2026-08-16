import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
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
  });

  Future<Either<Failure, void>> cancelRide(String rideId);

  /// Fetches all trips for the current authenticated user (passenger or captain)
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory();

  // For web-sockets / polling
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId);
}

