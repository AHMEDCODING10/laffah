import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

class CancelRideUseCase {
  final RideRepository repository;

  CancelRideUseCase(this.repository);

  Future<Either<Failure, void>> call(String rideId) async {
    return await repository.cancelRide(rideId);
  }
}
