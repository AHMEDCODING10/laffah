import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<BaseResponseModel<WalletModel>> getWalletBalance();
  Future<BaseResponseModel<List<Map<String, dynamic>>>> getCompanyAccounts();
  Future<BaseResponseModel<Map<String, dynamic>>> rechargeWallet({
    required double amount,
    required String paymentMethod,
    required String referenceId,
    String? senderAccount,
  });
  Future<BaseResponseModel<void>> requestPayout(
      double amount, String accountNumber);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioClient dioClient;

  WalletRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<WalletModel>> getWalletBalance() async {
    final response = await dioClient.dio.get(ApiEndpoints.walletBalance);
    return BaseResponseModel.fromJson(response.data,
        (data) => WalletModel.fromJson(data as Map<String, dynamic>));
  }

  @override
  Future<BaseResponseModel<List<Map<String, dynamic>>>> getCompanyAccounts() async {
    final response = await dioClient.dio.get(ApiEndpoints.walletCompanyAccounts);
    return BaseResponseModel.fromJson(response.data, (data) {
      if (data is List) {
        return List<Map<String, dynamic>>.from(data.map((x) => x as Map<String, dynamic>));
      }
      return <Map<String, dynamic>>[];
    });
  }

  @override
  Future<BaseResponseModel<Map<String, dynamic>>> rechargeWallet({
    required double amount,
    required String paymentMethod,
    required String referenceId,
    String? senderAccount,
  }) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.walletRecharge,
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
        'reference_id': referenceId,
        'sender_account': senderAccount,
      },
    );
    return BaseResponseModel.fromJson(response.data, (data) {
      if (data is Map<String, dynamic>) return data;
      return <String, dynamic>{};
    });
  }

  @override
  Future<BaseResponseModel<void>> requestPayout(
      double amount, String accountNumber) async {
    final response = await dioClient.dio.post(
      ApiEndpoints.requestPayout,
      data: {'amount': amount, 'account_number': accountNumber},
    );
    return BaseResponseModel.fromJson(response.data, (data) {});
  }
}
