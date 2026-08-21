import 'package:equatable/equatable.dart';
import '../../../domain/entities/captain_wallet_entity.dart';

abstract class CaptainWalletState extends Equatable {
  const CaptainWalletState();

  @override
  List<Object> get props => [];
}

class CaptainWalletInitial extends CaptainWalletState {}

class CaptainWalletLoading extends CaptainWalletState {}

class CaptainWalletLoaded extends CaptainWalletState {
  final CaptainWalletEntity wallet;

  const CaptainWalletLoaded({required this.wallet});

  @override
  List<Object> get props => [wallet];
}

class CaptainWalletError extends CaptainWalletState {
  final String message;

  const CaptainWalletError({required this.message});

  @override
  List<Object> get props => [message];
}
