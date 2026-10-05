import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/get_captain_wallet_usecase.dart';
import '../../../domain/repositories/captain_repository.dart';
import 'captain_wallet_event.dart';
import 'captain_wallet_state.dart';

class CaptainWalletBloc extends Bloc<CaptainWalletEvent, CaptainWalletState> {
  final GetCaptainWalletUseCase getCaptainWalletUseCase;
  final CaptainRepository repository;

  CaptainWalletBloc({
    required this.getCaptainWalletUseCase,
    required this.repository,
  }) : super(CaptainWalletInitial()) {
    on<FetchWalletDetails>(_onFetchWalletDetails);
    on<RequestPayoutEvent>(_onRequestPayout);
  }

  Future<void> _onFetchWalletDetails(
      FetchWalletDetails event, Emitter<CaptainWalletState> emit) async {
    if (!event.isSilent && state is! CaptainWalletLoaded) {
      emit(CaptainWalletLoading());
    }
    final failureOrWallet = await getCaptainWalletUseCase();
    failureOrWallet.fold(
      (failure) {
        if (state is! CaptainWalletLoaded) {
          emit(const CaptainWalletError(message: 'capt_wallet_err_fetch'));
        }
      },
      (wallet) => emit(CaptainWalletLoaded(wallet: wallet)),
    );
  }

  Future<void> _onRequestPayout(
      RequestPayoutEvent event, Emitter<CaptainWalletState> emit) async {
    // Optimistic UI update or just show loading, in a real app you might want a separate state
    // For now we just call the repository and then refetch
    final failureOrSuccess = await repository.requestPayout(
        event.amount, event.method, event.accountNumber);
    failureOrSuccess.fold(
      (failure) =>
          emit(const CaptainWalletError(message: 'capt_wallet_err_payout')),
      (_) {
        // After successful payout, fetch wallet details again
        add(const FetchWalletDetails());
      },
    );
  }
}
