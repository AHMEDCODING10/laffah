import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<BaseResponseModel<ProfileModel>> getProfile();
  Future<BaseResponseModel<ProfileModel>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,
  });
  Future<BaseResponseModel<List<SavedPlaceModel>>> getSavedPlaces();
  Future<BaseResponseModel<SavedPlaceModel>> addSavedPlace(
      SavedPlaceModel place);
  Future<BaseResponseModel<void>> deleteSavedPlace(String id);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<ProfileModel>> getProfile() async {
    final response = await dioClient.dio.get(ApiEndpoints.userProfile);
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<ProfileModel>> updateProfile({
    required String name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleModel,
    String? plateNumber,
    String? vehicleColor,
  }) async {
    final Map<String, dynamic> body = {'name': name};
    if (phone != null && phone.trim().isNotEmpty) {
      body['phone'] = phone.trim();
    }
    if (email != null && email.trim().isNotEmpty) {
      body['email'] = email.trim();
    }
    if (vehicleType != null && vehicleType.trim().isNotEmpty) {
      body['vehicle_type'] = vehicleType.trim();
    }
    if (vehicleModel != null && vehicleModel.trim().isNotEmpty) {
      body['vehicle_model'] = vehicleModel.trim();
    }
    if (plateNumber != null && plateNumber.trim().isNotEmpty) {
      body['plate_number'] = plateNumber.trim();
    }
    if (vehicleColor != null && vehicleColor.trim().isNotEmpty) {
      body['vehicle_color'] = vehicleColor.trim();
    }

    final response = await dioClient.dio.post(
      ApiEndpoints.updateProfile,
      data: body,
    );
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<List<SavedPlaceModel>>> getSavedPlaces() async {
    final response = await dioClient.dio.get(ApiEndpoints.savedPlaces);
    return BaseResponseModel.fromJson(
      response.data,
      (data) => (data as List)
          .map((e) => SavedPlaceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<BaseResponseModel<SavedPlaceModel>> addSavedPlace(
      SavedPlaceModel place) async {
    final response = await dioClient.dio
        .post(ApiEndpoints.savedPlaces, data: place.toJson());
    return BaseResponseModel.fromJson(
      response.data,
      (data) => SavedPlaceModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<void>> deleteSavedPlace(String id) async {
    final response =
        await dioClient.dio.delete('${ApiEndpoints.savedPlaces}/$id');
    return BaseResponseModel.fromJson(
      response.data,
      (_) {},
    );
  }
}
