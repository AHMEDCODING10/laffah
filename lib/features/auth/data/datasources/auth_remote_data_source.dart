import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<BaseResponseModel<String>> sendOtp(String phone);
  Future<BaseResponseModel<UserModel>> verifyOtp(String phone, String code);
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
    
    return BaseResponseModel.fromJson(response.data, (data) => data['verification_id'] as String);
  }

  @override
  Future<BaseResponseModel<UserModel>> verifyOtp(String phone, String code) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.verifyOtp,
      data: {'phone': phone, 'code': code},
    );
    
    return BaseResponseModel.fromJson(response.data, (data) => UserModel.fromJson(data as Map<String, dynamic>));
  }
}
