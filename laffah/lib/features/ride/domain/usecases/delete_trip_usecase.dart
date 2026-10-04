import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

class DeleteTripUseCase {
  final RideRepository repository;

  const DeleteTripUseCase(this.repository);

  Future<Either<Failure, void>> call(String tripId, {bool isParcel = false}) {
    return repository.deleteTrip(tripId, isParcel: isParcel);
  }
}
