import 'package:dio/dio.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/captain_status_model.dart';

abstract class CaptainRemoteDataSource {
  Future<BaseResponseModel<CaptainStatusModel>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  });

  Future<BaseResponseModel<void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  });
}

class CaptainRemoteDataSourceImpl implements CaptainRemoteDataSource {
  final DioClient dioClient;

  CaptainRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<CaptainStatusModel>> toggleOnlineStatus({
    required bool isOnline,
    required double lat,
    required double lng,
  }) async {
    final response = await dioClient.dio.post(
      '/captain/status/toggle',
      data: {
        'is_online': isOnline,
        'lat': lat,
        'lng': lng,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) => CaptainStatusModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<void>> respondToTripRequest({
    required String tripId,
    required bool accept,
  }) async {
    final response = await dioClient.dio.post(
      '/captain/trip/$tripId/respond',
      data: {
        'accept': accept,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) => null);
  }
}
