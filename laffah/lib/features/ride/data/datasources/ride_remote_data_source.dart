import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/ride_model.dart';

abstract class RideRemoteDataSource {
  Future<BaseResponseModel<RideModel>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String rideType,
    required double expectedPrice,
    List<Map<String, dynamic>>? stops,
    int? promoCodeId,
    bool isScheduled = false,
    DateTime? scheduledTime,
    String paymentMethod = 'cash',
  });

  Future<Map<String, dynamic>> estimateFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    List<Map<String, dynamic>>? stops,
  });

  Future<BaseResponseModel<RideModel>> trackRide(String rideId);
  Future<BaseResponseModel<void>> cancelRide(String rideId, {bool isParcel = false});
  Future<BaseResponseModel<RideModel>> retryRide(String rideId);

  /// Returns the raw list of trip maps from the backend
  Future<List<Map<String, dynamic>>> getTripHistory();

  /// Rates a completed trip on the backend
  Future<BaseResponseModel<void>> rateTrip({
    required String tripId,
    required double rating,
    String? review,
  });

  /// Deletes a trip from the backend server
  Future<void> deleteTrip(String tripId, {bool isParcel = false});
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final DioClient dioClient;

  RideRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<RideModel>> requestRide({
    required String pickupLocation,
    required String dropoffLocation,
    double? pickupLatitude,
    double? pickupLongitude,
    double? dropoffLatitude,
    double? dropoffLongitude,
    required String rideType,
    required double expectedPrice,
    List<Map<String, dynamic>>? stops,
    int? promoCodeId,
    bool isScheduled = false,
    DateTime? scheduledTime,
    String paymentMethod = 'cash',
  }) async {
    final Map<String, dynamic> payload = {
      'type': rideType == 'delivery' ? 'delivery' : 'ride',
      'pickup_address': pickupLocation,
      'pickup_location': pickupLocation,
      'pickup_latitude': pickupLatitude ?? 15.3694,
      'pickup_longitude': pickupLongitude ?? 44.1910,
      'dropoff_address': dropoffLocation,
      'dropoff_location': dropoffLocation,
      'dropoff_latitude': dropoffLatitude ?? 15.3521,
      'dropoff_longitude': dropoffLongitude ?? 44.2014,
      'expected_price': expectedPrice,
      'payment_method': paymentMethod,
    };

    if (stops != null && stops.isNotEmpty) {
      payload['stops'] = stops;
    }

    if (promoCodeId != null) {
      payload['promo_code_id'] = promoCodeId;
    }
    
    if (isScheduled && scheduledTime != null) {
      payload['is_scheduled'] = true;
      payload['scheduled_time'] = scheduledTime.toIso8601String();
    }

    final response = await dioClient.dio.post(
      ApiEndpoints.requestRide,
      data: payload,
    );

    return BaseResponseModel.fromJson(
      response.data,
      (data) => RideModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<Map<String, dynamic>> estimateFare({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropoffLatitude,
    required double dropoffLongitude,
    List<Map<String, dynamic>>? stops,
  }) async {
    final Map<String, dynamic> payload = {
      'pickup_latitude': pickupLatitude,
      'pickup_longitude': pickupLongitude,
      'dropoff_latitude': dropoffLatitude,
      'dropoff_longitude': dropoffLongitude,
      if (stops != null && stops.isNotEmpty) 'stops': stops,
    };
    final response = await dioClient.dio.post(
      ApiEndpoints.estimateRide,
      data: payload,
    );
    final data = response.data;
    if (data is Map && data['data'] != null) {
      return Map<String, dynamic>.from(data['data'] as Map);
    }
    return {};
  }

  @override
  Future<BaseResponseModel<RideModel>> trackRide(String rideId) async {
    final response = await dioClient.dio.get(ApiEndpoints.trackRide(rideId));
    return BaseResponseModel.fromJson(
      response.data,
      (data) => RideModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<void>> cancelRide(String rideId, {bool isParcel = false}) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.cancelRide(rideId),
      data: {
        'reason': 'إلغاء من قبل الراكب',
        if (isParcel) 'type': 'parcel',
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }

  @override
  Future<BaseResponseModel<RideModel>> retryRide(String rideId) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.retryRide(rideId),
    );
    return BaseResponseModel.fromJson(
      response.data,
      (data) => RideModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getTripHistory() async {
    final response = await dioClient.dio.get(ApiEndpoints.tripHistory);
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      final list = data['data'] as List? ?? [];
      return list.map((e) => e as Map<String, dynamic>).toList();
    }
    return [];
  }

  @override
  Future<BaseResponseModel<void>> rateTrip({
    required String tripId,
    required double rating,
    String? review,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.rateTrip(tripId),
      data: {
        'rating': rating,
        'review': review ?? 'تجربة ممتازة مع لَفَّة',
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }

  @override
  Future<void> deleteTrip(String tripId, {bool isParcel = false}) async {
    final queryParams = isParcel ? '?type=parcel' : '';
    await dioClient.dio.delete('/trips/$tripId$queryParams');
  }
}

