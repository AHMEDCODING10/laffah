import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class RequestRideUseCase {
  final RideRepository repository;

  RequestRideUseCase(this.repository);

  Future<Either<Failure, RideEntity>> call({
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
  }) async {
    if (pickupLocation.isEmpty || dropoffLocation.isEmpty) {
      return const Left(ValidationFailure('يرجى تحديد نقطة الانطلاق والوصول'));
    }
    return await repository.requestRide(
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
    );
  }
}

