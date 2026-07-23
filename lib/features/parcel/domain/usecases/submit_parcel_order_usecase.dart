import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parcel_entity.dart';
import '../repositories/parcel_repository.dart';

class SubmitParcelOrderUseCase {
  final ParcelRepository repository;

  SubmitParcelOrderUseCase(this.repository);

  Future<Either<Failure, ParcelEntity>> call({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
    required String size,
    required String notes,
  }) async {
    return await repository.submitParcelOrder(
      senderName: senderName,
      senderPhone: senderPhone,
      receiverName: receiverName,
      receiverPhone: receiverPhone,
      parcelType: parcelType,
      size: size,
      notes: notes,
    );
  }
}
