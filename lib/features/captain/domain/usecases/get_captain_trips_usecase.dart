import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_trip_entity.dart';
import '../repositories/captain_repository.dart';

class GetCaptainTripsUseCase {
  final CaptainRepository repository;

  GetCaptainTripsUseCase(this.repository);

  Future<Either<Failure, List<CaptainTripEntity>>> call({
    required int page,
    String statusFilter = 'الكل',
  }) async {
    return await repository.getCaptainTrips(
      page: page,
      statusFilter: statusFilter,
    );
  }
}
