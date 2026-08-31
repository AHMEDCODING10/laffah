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
    return await repository.submitParcelOrder(
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
  }
}

