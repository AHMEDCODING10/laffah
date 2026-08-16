import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/websocket_client.dart';
import '../models/captain_status_model.dart';

import 'dart:io';
import 'package:dio/dio.dart';

abstract class CaptainRemoteDataSource {
  Future<BaseResponseModel<CaptainStatusModel>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  });

  Future<void> updateLocation({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  });

  Future<BaseResponseModel<void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  });

  Future<BaseResponseModel<void>> updateTripStatus({
    required String tripId,
    required String status,
  });

  Future<BaseResponseModel<void>> requestPayout(
      double amount, String method, String accountNumber);
  Future<BaseResponseModel<Map<String, dynamic>>> fetchBonusData();
  Future<BaseResponseModel<Map<String, dynamic>>> getWalletDetails();
  Future<BaseResponseModel<List<dynamic>>> getNotifications();
  Future<BaseResponseModel<List<dynamic>>> getNearbyRequests();
  Future<BaseResponseModel<List<dynamic>>> getCaptainTrips(
      int page, String statusFilter);
  Future<BaseResponseModel<Map<String, dynamic>>> uploadDocument(
      File file, String type);
}

class CaptainRemoteDataSourceImpl implements CaptainRemoteDataSource {
  final DioClient dioClient;
  final LaffahWebSocketClient wsClient;

  CaptainRemoteDataSourceImpl(this.dioClient, this.wsClient);

  @override
  Future<BaseResponseModel<void>> updateTripStatus({
    required String tripId,
    required String status,
  }) async {
    final response = await dioClient.dio.post(
      '/trips/$tripId/status',
      data: {'status': status},
    );
    return BaseResponseModel.fromJson(response.data, (_) {});
  }

  @override
  Future<BaseResponseModel<CaptainStatusModel>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.toggleOnlineStatus,
      data: {
        'is_online': isOnline,
        'lat': lat,
        'lng': lng,
        'latitude': lat,
        'longitude': lng,
      },
    );
    return BaseResponseModel.fromJson(response.data,
        (data) => CaptainStatusModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  }) async {
    final endpoint = accept
        ? ApiEndpoints.respondToTrip(tripId)
        : '/trips/$tripId/reject';
    final response = await dioClient.dio.post(
      endpoint,
      data: {
        'accept': accept,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }

  @override
  Future<BaseResponseModel<void>> requestPayout(
      double amount, String method, String accountNumber) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.requestPayout,
      data: {
        'amount': amount,
        'payout_method': method,
        'payment_method': method,
        'account_number': accountNumber,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> fetchBonusData() async {
    final response = await dioClient.dio.get(ApiEndpoints.captainBonus);
    return BaseResponseModel.fromJson(
        response.data, (data) => data as Map<String, dynamic>);
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> getWalletDetails() async {
    final response = await dioClient.dio.get('/wallet/balance');
    return BaseResponseModel.fromJson(
        response.data, (data) => data as Map<String, dynamic>);
  }

  @override
  Future<BaseResponseModel<List<dynamic>>> getNotifications() async {
    final response = await dioClient.dio.get(ApiEndpoints.captainNotifications);
    return BaseResponseModel.fromJson(response.data, (data) {
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as List<dynamic>;
      }
      return [];
    });
  }

  @override
  Future<BaseResponseModel<List<dynamic>>> getNearbyRequests() async {
    final response =
        await dioClient.dio.get(ApiEndpoints.captainNearbyRequests);
    return BaseResponseModel.fromJson(response.data, (data) {
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as List<dynamic>;
      }
      return [];
    });
  }

  @override
  Future<BaseResponseModel<List<dynamic>>> getCaptainTrips(
      int page, String statusFilter) async {
    final response = await dioClient.dio.get(
      ApiEndpoints.tripHistory,
      queryParameters: {
        'page': page,
        'status_filter': statusFilter,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {
      if (data is List) return data;
      if (data is Map && data.containsKey('data')) {
        return data['data'] as List<dynamic>;
      }
      return [];
    });
  }

  @override
  Future<void> updateLocation({
    required String captainId,
    required double lat,
    required double lng,
    required double heading,
  }) async {
    try {
      await dioClient.dio.post(
        ApiEndpoints.updateCaptainLocation,
        data: {
          'latitude': lat,
          'longitude': lng,
          'lat': lat,
          'lng': lng,
          'heading': heading,
        },
      );
    } catch (e) {
      // Non-blocking location update failure
    }
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> uploadDocument(
      File file, String type) async {
    final formData = FormData.fromMap({
      'type': type,
      'document_type': type,
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await dioClient.dio.post(
      ApiEndpoints.captainDocuments,
      data: formData,
    );

    return BaseResponseModel.fromJson(
      response.data,
      (data) => data as Map<String, dynamic>,
    );
  }
}