import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<GetWalletBalanceEvent>(_onGetWalletBalance);
    on<GetCompanyAccountsEvent>(_onGetCompanyAccounts);
    on<RechargeWalletEvent>(_onRechargeWallet);
    on<RequestPayoutEvent>(_onRequestPayout);
    on<ResetWalletEvent>((event, emit) => emit(WalletInitial()));
  }

  Future<void> _onGetWalletBalance(
      GetWalletBalanceEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await repository.getWalletBalance();
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (wallet) => emit(WalletBalanceLoaded(wallet)),
    );
  }

  Future<void> _onGetCompanyAccounts(
      GetCompanyAccountsEvent event, Emitter<WalletState> emit) async {
    final result = await repository.getCompanyAccounts();
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (accounts) => emit(CompanyAccountsLoaded(accounts)),
    );
  }

  Future<void> _onRechargeWallet(
      RechargeWalletEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result = await repository.rechargeWallet(
      amount: event.amount,
      paymentMethod: event.paymentMethod,
      referenceId: event.referenceId,
      senderAccount: event.senderAccount,
    );
    await result.fold(
      (failure) async => emit(WalletError(failure.message)),
      (data) async {
        final newBal = (data['new_balance'] as num?)?.toDouble() ?? 0.0;
        emit(WalletRechargeSuccess(
          message: 'تم شحن رصيد المحفظة بنجاح!',
          newBalance: newBal,
        ));
        // Refresh balance automatically
        final balanceRes = await repository.getWalletBalance();
        balanceRes.fold(
          (_) {},
          (wallet) => emit(WalletBalanceLoaded(wallet)),
        );
      },
    );
  }

  Future<void> _onRequestPayout(
      RequestPayoutEvent event, Emitter<WalletState> emit) async {
    emit(WalletLoading());
    final result =
        await repository.requestPayout(event.amount, event.accountNumber);
    result.fold(
      (failure) => emit(WalletError(failure.message)),
      (_) => emit(WalletPayoutRequested()),
    );
  }
}
