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
    required String rideType,
    required double expectedPrice,
  }) async {
    if (pickupLocation.isEmpty || dropoffLocation.isEmpty) {
      return const Left(ValidationFailure('يرجى تحديد نقطة الانطلاق والوصول'));
    }
    return await repository.requestRide(
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      rideType: rideType,
      expectedPrice: expectedPrice,
    );
  }
}
