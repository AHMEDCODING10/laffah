import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

/// RateTripUseCase — Allows passenger or captain to rate a completed trip.
class RateTripUseCase {
  final RideRepository repository;

  RateTripUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String tripId,
    required double rating,
    String? review,
  }) async {
    return await repository.rateTrip(
      tripId: tripId,
      rating: rating,
      review: review,
    );
  }
}
