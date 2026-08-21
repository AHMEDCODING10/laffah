import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class UpdateTripStatusUseCase {
  final CaptainRepository repository;

  UpdateTripStatusUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String tripId,
    required String status,
  }) async {
    return await repository.updateTripStatus(
      tripId: tripId,
      status: status,
    );
  }
}
