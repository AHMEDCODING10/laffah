import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<BaseResponseModel<String>> sendOtp(String phone);
  Future<BaseResponseModel<UserModel>> verifyOtp(String phone, String code, {String role = 'passenger'});
  Future<BaseResponseModel<UserModel>> registerPassenger(Map<String, dynamic> data);
  Future<BaseResponseModel<UserModel>> registerCaptain(Map<String, dynamic> data);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<String>> sendOtp(String phone) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.sendOtp,
      data: {'phone': phone},
    );
    return BaseResponseModel.fromJson(response.data, (data) => data['dev_otp']?.toString() ?? '');
  }

  @override
  Future<BaseResponseModel<UserModel>> verifyOtp(String phone, String code, {String role = 'passenger'}) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'otp': code, 'role': role},
    );
    
    return BaseResponseModel.fromJson(response.data, (data) => UserModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<UserModel>> registerPassenger(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.registerPassenger,
      data: data,
    );
    return BaseResponseModel.fromJson(response.data, (data) => UserModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<UserModel>> registerCaptain(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.registerCaptain,
      data: data,
    );
    return BaseResponseModel.fromJson(response.data, (data) => UserModel.fromJson(data as Map<String, dynamic>));
  }
}
