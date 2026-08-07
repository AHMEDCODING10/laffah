import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/ride_repository.dart';

/// GetTripHistoryUseCase - Fetches all trips for the current user from the backend.
class GetTripHistoryUseCase {
  final RideRepository repository;

  GetTripHistoryUseCase(this.repository);

  Future<Either<Failure, List<Map<String, dynamic>>>> call() async {
    return await repository.getTripHistory();
  }
}
