import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_status_entity.dart';

abstract class CaptainRepository {
  Future<Either<Failure, CaptainStatusEntity>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  });
  
  Future<Either<Failure, void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  });
}
