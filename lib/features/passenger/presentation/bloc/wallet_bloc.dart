import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/wallet_repository.dart';
import 'wallet_event.dart';
import 'wallet_state.dart';

class WalletBloc extends Bloc<WalletEvent, WalletState> {
  final WalletRepository repository;

  WalletBloc({required this.repository}) : super(WalletInitial()) {
    on<GetWalletBalanceEvent>(_onGetWalletBalance);
    on<RequestPayoutEvent>(_onRequestPayout);
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
