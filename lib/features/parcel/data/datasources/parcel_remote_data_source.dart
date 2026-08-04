import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/parcel_model.dart';

abstract class ParcelRemoteDataSource {
  Future<BaseResponseModel<ParcelModel>> submitParcelOrder({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
    required String size,
    required String notes,
  });
}

class ParcelRemoteDataSourceImpl implements ParcelRemoteDataSource {
  final DioClient dioClient;

  ParcelRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<ParcelModel>> submitParcelOrder({
    required String senderName,
    required String senderPhone,
    required String receiverName,
    required String receiverPhone,
    required String parcelType,
    required String size,
    required String notes,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.submitParcel,
      data: {
        'sender_name': senderName,
        'sender_phone': senderPhone,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'parcel_type': parcelType,
        'size': size,
        'notes': notes,
      },
    );
    return BaseResponseModel.fromJson(
      response.data, 
      (data) => ParcelModel.fromJson(data as Map<String, dynamic>)
    );
  }
}
