import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parcel_entity.dart';

abstract class ParcelRepository {
  Future<Either<Failure, ParcelEntity>> submitParcelOrder({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
    required String size,
    required String notes,
  });
}
