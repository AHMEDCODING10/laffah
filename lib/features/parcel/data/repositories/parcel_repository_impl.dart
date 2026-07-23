import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/parcel_entity.dart';
import '../../domain/repositories/parcel_repository.dart';
import '../datasources/parcel_remote_data_source.dart';

class ParcelRepositoryImpl implements ParcelRepository {
  final ParcelRemoteDataSource remoteDataSource;

  ParcelRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ParcelEntity>> submitParcelOrder({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
    required String size,
    required String notes,
  }) async {
    try {
      final response = await remoteDataSource.submitParcelOrder(
        senderName: senderName,
        senderPhone: senderPhone,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        parcelType: parcelType,
        size: size,
        notes: notes,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (_) {
      return const Left(ServerFailure('حدث خطأ أثناء الاتصال بالخادم لتقديم طلب الطرد'));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
