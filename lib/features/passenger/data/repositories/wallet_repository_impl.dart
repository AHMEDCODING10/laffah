import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../datasources/wallet_remote_data_source.dart';

class WalletRepositoryImpl implements WalletRepository {
  final WalletRemoteDataSource remoteDataSource;

  WalletRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, WalletEntity>> getWalletBalance() async {
    try {
      final response = await remoteDataSource.getWalletBalance();
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء تحميل بيانات المحفظة'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> requestPayout(double amount, String accountNumber) async {
    try {
      final response = await remoteDataSource.requestPayout(amount, accountNumber);
      if (response.success) {
        return const Right(null);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء طلب السحب'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
