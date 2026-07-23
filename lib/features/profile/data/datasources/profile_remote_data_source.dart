import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/profile_model.dart';
import '../models/saved_place_model.dart';

abstract class ProfileRemoteDataSource {
  Future<BaseResponseModel<ProfileModel>> getProfile();
  Future<BaseResponseModel<ProfileModel>> updateProfile({required String name, String? email});
  Future<BaseResponseModel<List<SavedPlaceModel>>> getSavedPlaces();
  Future<BaseResponseModel<SavedPlaceModel>> addSavedPlace(SavedPlaceModel place);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final DioClient dioClient;

  ProfileRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<ProfileModel>> getProfile() async {
    final response = await dioClient.dio.get('/user/profile');
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<ProfileModel>> updateProfile({required String name, String? email}) async {
    final response = await dioClient.dio.post(
      '/user/profile/update',
      data: {'name': name, 'email': email},
    );
    return BaseResponseModel.fromJson(
      response.data,
      (data) => ProfileModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<BaseResponseModel<List<SavedPlaceModel>>> getSavedPlaces() async {
    final response = await dioClient.dio.get('/user/saved-places');
    return BaseResponseModel.fromJson(
      response.data,
      (data) => (data as List).map((e) => SavedPlaceModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  @override
  Future<BaseResponseModel<SavedPlaceModel>> addSavedPlace(SavedPlaceModel place) async {
    final response = await dioClient.dio.post('/user/saved-places', data: place.toJson());
    return BaseResponseModel.fromJson(
      response.data,
      (data) => SavedPlaceModel.fromJson(data as Map<String, dynamic>),
    );
  }
}
