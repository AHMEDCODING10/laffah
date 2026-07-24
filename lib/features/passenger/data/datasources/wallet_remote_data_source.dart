import '../../../../core/network/base_response_model.dart';
import '../../../../core/network/dio_client.dart';
import '../models/wallet_model.dart';

abstract class WalletRemoteDataSource {
  Future<BaseResponseModel<WalletModel>> getWalletBalance();
  Future<BaseResponseModel<void>> requestPayout(double amount, String accountNumber);
}

class WalletRemoteDataSourceImpl implements WalletRemoteDataSource {
  final DioClient dioClient;

  WalletRemoteDataSourceImpl(this.dioClient);

  @override
  Future<BaseResponseModel<WalletModel>> getWalletBalance() async {
    final response = await dioClient.dio.get('/wallet/balance');
    return BaseResponseModel.fromJson(
      response.data, 
      (data) => WalletModel.fromJson(data as Map<String, dynamic>)
    );
  }

  @override
  Future<BaseResponseModel<void>> requestPayout(double amount, String accountNumber) async {
    final response = await dioClient.dio.post(
      '/wallet/payout',
      data: {'amount': amount, 'account_number': accountNumber},
    );
    return BaseResponseModel.fromJson(response.data, (data) => null);
  }
}
