import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/captain_repository.dart';

class FetchBonusDataUseCase {
  final CaptainRepository repository;

  FetchBonusDataUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call() async {
    return await repository.fetchBonusData();
  }
}
