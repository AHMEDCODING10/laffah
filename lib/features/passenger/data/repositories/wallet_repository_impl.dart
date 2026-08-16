import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  static const WalletEntity _emptyWallet = WalletEntity(
    balance: 0.0,
    transactions: [],
  );

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance() async {
    try {
      final response = await remoteDataSource.getWalletBalance();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return const Right(_emptyWallet);
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'حدث خطأ أثناء تحميل بيانات المحفظة';
      return Left(ServerFailure(msg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getCompanyAccounts() async {
    try {
      final response = await remoteDataSource.getCompanyAccounts();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل جلب حسابات الدفع';
      return Left(ServerFailure(msg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> rechargeWallet({
    required double amount,
    required String paymentMethod,
    required String referenceId,
    String? senderAccount,
  }) async {
    try {
      final response = await remoteDataSource.rechargeWallet(
        amount: amount,
        paymentMethod: paymentMethod,
        referenceId: referenceId,
        senderAccount: senderAccount,
      );
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'فشل تنفيذ عملية الشحن';
      return Left(ServerFailure(msg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPayout(
      double amount, String accountNumber) async {
    try {
      final response =
          await remoteDataSource.requestPayout(amount, accountNumber);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'حدث خطأ أثناء طلب السحب';
      return Left(ServerFailure(msg.toString()));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
