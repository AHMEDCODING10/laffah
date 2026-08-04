import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/captain_wallet_entity.dart';
import '../repositories/captain_repository.dart';

class GetCaptainWalletUseCase {
  final CaptainRepository repository;

  GetCaptainWalletUseCase(this.repository);

  Future<Either<Failure, CaptainWalletEntity>> call() async {
    return await repository.getWalletDetails();
  }
}
