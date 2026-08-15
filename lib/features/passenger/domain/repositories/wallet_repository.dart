import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<Either<Failure, WalletEntity>> getWalletBalance();
  Future<Either<Failure, List<Map<String, dynamic>>>> getCompanyAccounts();
  Future<Either<Failure, Map<String, dynamic>>> rechargeWallet({
    required double amount,
    required String paymentMethod,
    required String referenceId,
    String? senderAccount,
  });
  Future<Either<Failure, void>> requestPayout(
      double amount, String accountNumber);
}
