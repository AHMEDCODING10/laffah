import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {

  Future<BaseResponseModel<UserModel>> registerPassenger(Map<String, dynamic> data);
  Future<BaseResponseModel<UserModel>> registerCaptain(Map<String, dynamic> data);
  Future<BaseResponseModel<UserModel>> login(String phone, String password);
  Future<void> logoutFromServer();
  Future<BaseResponseModel<dynamic>> forgotPassword(String phone);
  Future<BaseResponseModel<dynamic>> verifyResetCode(String phone, String code);
  Future<BaseResponseModel<dynamic>> resetPassword(String phone, String code, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl(this.dioClient);


  @override
  Future<BaseResponseModel<UserModel>> login(String phone, String password) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.login,
      data: {'phone': phone, 'password': password},
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

  @override
  Future<void> logoutFromServer() async {
    await dioClient.dio.post(ApiEndpoints.logout);
  }

  @override
  Future<BaseResponseModel<dynamic>> forgotPassword(String phone) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.forgotPassword,
      data: {'phone': phone},
    );
    return BaseResponseModel.fromJson(response.data, (data) => data);
  }

  @override
  Future<BaseResponseModel<dynamic>> verifyResetCode(String phone, String code) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.verifyResetCode,
      data: {'phone': phone, 'code': code},
    );
    return BaseResponseModel.fromJson(response.data, (data) => data);
  }

  @override
  Future<BaseResponseModel<dynamic>> resetPassword(String phone, String code, String newPassword) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.resetPassword,
      data: {'phone': phone, 'code': code, 'password': newPassword},
    );
    return BaseResponseModel.fromJson(response.data, (data) => data);
  }
}
