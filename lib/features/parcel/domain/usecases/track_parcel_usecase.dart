import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parcel_entity.dart';
import '../repositories/parcel_repository.dart';

class TrackParcelUseCase {
  final ParcelRepository repository;

  TrackParcelUseCase(this.repository);

  Future<Either<Failure, ParcelEntity>> call(String identifier) async {
    return await repository.trackParcel(identifier);
  }
}
