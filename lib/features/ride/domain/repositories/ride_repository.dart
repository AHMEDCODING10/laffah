import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';

abstract class RideRepository {
  Future<Either<Failure, RideEntity>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    required String rideType, // 'motorcycle' or 'car'
    required double expectedPrice,
  });

  Future<Either<Failure, void>> cancelRide(String rideId);
  
  // For web-sockets / polling
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId);
}
