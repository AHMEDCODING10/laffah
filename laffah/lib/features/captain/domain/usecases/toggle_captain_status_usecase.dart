import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_status_entity.dart';
import '../repositories/captain_repository.dart';

class ToggleCaptainStatusUseCase {
  final CaptainRepository repository;

  ToggleCaptainStatusUseCase(this.repository);

  Future<Either<Failure, CaptainStatusEntity>> call({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    return await repository.toggleOnlineStatus(
      isOnline: isOnline,
      lat: lat,
      lng: lng,
    );
  }
}
