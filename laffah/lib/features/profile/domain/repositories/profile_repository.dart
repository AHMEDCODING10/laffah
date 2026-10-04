import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/profile_entity.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileEntity>> getProfile();
  Future<Either<Failure, ProfileEntity>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,
  });
  Future<Either<Failure, List<SavedPlaceEntity>>> getSavedPlaces();
  Future<Either<Failure, SavedPlaceEntity>> addSavedPlace(
      SavedPlaceEntity place);
}
