import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

class EstimateTripFareUseCase {
  final RideRepository repository;

  const EstimateTripFareUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    List<Map<String, dynamic>>? stops,
  }) {
    return repository.estimateFare(
      pickupLatitude: pickupLatitude,
      pickupLongitude: pickupLongitude,
      dropoffLatitude: dropoffLatitude,
      dropoffLongitude: dropoffLongitude,
      stops: stops,
    );
  }
}
