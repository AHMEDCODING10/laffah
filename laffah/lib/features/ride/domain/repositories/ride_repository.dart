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
    bool isScheduled = false,
    DateTime? scheduledTime,
  });

  Future<Either<Failure, RideEntity>> trackRide(String rideId);
  Future<Either<Failure, void>> cancelRide(String rideId, {bool isParcel = false});

  /// Fetches all trips for the current authenticated user (passenger or captain)
  Future<Either<Failure, List<Map<String, dynamic>>>> getTripHistory();

  /// Rates a completed trip
  Future<Either<Failure, void>> rateTrip({
    required String tripId,
    required double rating,
    String? review,
  });

  /// Deletes a trip from history and database
  Future<Either<Failure, void>> deleteTrip(String tripId);

  // For web-sockets / polling
  Stream<Either<Failure, RideEntity>> trackRideStatus(String rideId);
}

