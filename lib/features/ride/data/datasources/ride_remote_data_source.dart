import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ride_model.dart';

abstract class RideRemoteDataSource {
  Future<BaseResponseModel<RideModel>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    required String rideType,
    required double expectedPrice,
  });

  Future<BaseResponseModel<void>> cancelRide(String rideId);
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final DioClient dioClient;

  RideRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<RideModel>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    required String rideType,
    required double expectedPrice,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.requestRide,
      data: {
        'pickup_location': pickupLocation,
        'dropoff_location': dropoffLocation,
        'ride_type': rideType,
        'expected_price': expectedPrice,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) => RideModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<void>> cancelRide(String rideId) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.cancelRide(rideId),
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }
}
