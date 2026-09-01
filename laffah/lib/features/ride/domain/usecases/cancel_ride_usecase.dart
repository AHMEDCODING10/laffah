import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

class CancelRideUseCase {
  final RideRepository repository;

  CancelRideUseCase(this.repository);

  Future<Either<Failure, void>> call(String rideId, {bool isParcel = false}) {
    return repository.cancelRide(rideId, isParcel: isParcel);
  }
}
