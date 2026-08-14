import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWalletBalance();
  Future<Either<Failure, void>> requestPayout(
      double amount, String accountNumber);
}
