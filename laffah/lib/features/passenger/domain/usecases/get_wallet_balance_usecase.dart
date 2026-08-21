import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class GetWalletBalanceUseCase {
  final WalletRepository repository;

  GetWalletBalanceUseCase(this.repository);

  Future<Either<Failure, WalletEntity>> call() async {
    return await repository.getWalletBalance();
  }
}
