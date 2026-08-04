import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_trip_request_entity.dart';
import '../repositories/captain_repository.dart';

class GetCaptainNearbyRequestsUseCase {
  final CaptainRepository repository;

  GetCaptainNearbyRequestsUseCase(this.repository);

  Future<Either<Failure, List<CaptainTripRequestEntity>>> call() async {
    return await repository.getNearbyRequests();
  }
}
