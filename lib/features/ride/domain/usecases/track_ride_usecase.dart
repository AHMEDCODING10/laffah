import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/ride_entity.dart';
import '../repositories/ride_repository.dart';

class TrackRideUseCase {
  final RideRepository repository;

  TrackRideUseCase(this.repository);

  Stream<Either<Failure, RideEntity>> call(String rideId) {
    return repository.trackRideStatus(rideId);
  }
}
