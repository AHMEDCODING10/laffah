import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class RetryRideUseCase {
  final RideRepository repository;

  RetryRideUseCase(this.repository);

  Future<Either<Failure, RideEntity>> call(String rideId) {
    return repository.retryRide(rideId);
  }
}
