import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet_entity.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletBalanceLoaded extends WalletState {
  final WalletEntity wallet;

  const WalletBalanceLoaded(this.wallet);

  @override
  List<Object?> get props => [wallet];
}

class CompanyAccountsLoaded extends WalletState {
  final List<Map<String, dynamic>> accounts;

  const CompanyAccountsLoaded(this.accounts);

  @override
  List<Object?> get props => [accounts];
}

class WalletRechargeSuccess extends WalletState {
  final String message;
  final double newBalance;

  const WalletRechargeSuccess({required this.message, required this.newBalance});

  @override
  List<Object?> get props => [message, newBalance];
}

class WalletPayoutRequested extends WalletState {}

class WalletError extends WalletState {
  final String message;

  const WalletError(this.message);

  @override
  List<Object?> get props => [message];
}
