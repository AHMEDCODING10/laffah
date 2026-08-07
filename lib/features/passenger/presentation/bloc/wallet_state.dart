import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletBalanceLoaded extends WalletState {
  final WalletEntity wallet;

  const WalletBalanceLoaded(this.wallet);

  @override
  List<Object> get props => [wallet];
}

class WalletPayoutRequested extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object> get props => [message];
}
