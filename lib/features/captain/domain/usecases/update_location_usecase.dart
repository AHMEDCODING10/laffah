import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class UpdateLocationUseCase {
  final CaptainRepository repository;

  UpdateLocationUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  }) async {
    return await repository.updateLocation(
      captainId: captainId,
      lat: lat,
      lng: lng,
      heading: heading,
    );
  }
}
