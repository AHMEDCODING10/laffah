import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class RespondToTripUseCase {
  final CaptainRepository repository;

  RespondToTripUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String tripId,
    required bool accept,
    bool isParcel = false,
  }) async {
    return await repository.respondToTripRequest(
      tripId: tripId,
      accept: accept,
      isParcel: isParcel,
    );
  }
}