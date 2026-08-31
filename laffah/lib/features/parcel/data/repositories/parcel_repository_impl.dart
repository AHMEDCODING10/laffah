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
    String? pickupAddress,
    double? pickupLatitude,
    double? pickupLongitude,
    String? dropoffAddress,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String parcelType,
    required String size,
    required String notes,
    double? price,
    double? distance,
  }) async {
    try {
      final response = await remoteDataSource.submitParcelOrder(
        senderName: senderName,
        senderPhone: senderPhone,
        receiverName: receiverName,
        receiverPhone: receiverPhone,
        pickupAddress: pickupAddress,
        pickupLatitude: pickupLatitude,
        pickupLongitude: pickupLongitude,
        dropoffAddress: dropoffAddress,
        dropoffLatitude: dropoffLatitude,
        dropoffLongitude: dropoffLongitude,
        parcelType: parcelType,
        size: size,
        notes: notes,
        price: price,
        distance: distance,
      );

      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : 'حدث خطأ أثناء الاتصال بالخادم لتقديم طلب الطرد';
      return Left(ServerFailure(errorMsg!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParcelEntity>> trackParcel(String identifier) async {
    try {
      final response = await remoteDataSource.trackParcel(identifier);
      if (response.success && response.data != null) {
        return Right(response.data!);
      } else {
        return Left(ServerFailure(response.message));
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message'].toString()
          : 'تعذر جلب بيانات تتبع الطرد من الخادم';
      return Left(ServerFailure(errorMsg!));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

}
