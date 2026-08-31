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
  });
  Future<BaseResponseModel<ParcelModel>> trackParcel(String identifier);
}

class ParcelRemoteDataSourceImpl implements ParcelRemoteDataSource {
  final DioClient dioClient;

  ParcelRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<ParcelModel>> trackParcel(String identifier) async {
    final response = await dioClient.dio.get(ApiEndpoints.trackParcel(identifier));
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ParcelModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<ParcelModel>> submitParcelOrder({

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
    final response = await dioClient.dio.post(
      ApiEndpoints.submitParcel,
      data: {
        'sender_name': senderName,
        'sender_phone': senderPhone,
        'receiver_name': receiverName,
        'receiver_phone': receiverPhone,
        'pickup_address': pickupAddress ?? 'صنعاء',
        'pickup_latitude': pickupLatitude ?? 15.3694,
        'pickup_longitude': pickupLongitude ?? 44.1910,
        'dropoff_address': dropoffAddress ?? 'صنعاء',
        'dropoff_latitude': dropoffLatitude ?? 15.3521,
        'dropoff_longitude': dropoffLongitude ?? 44.2014,
        'parcel_type': parcelType,
        'size': size,
        'notes': notes,
        if (price != null) 'price': price,
        if (distance != null) 'distance': distance,
      },
    );
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ParcelModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

