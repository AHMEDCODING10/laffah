import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object> get props => [];
}

class GetWalletBalanceEvent extends WalletEvent {}

class RequestPayoutEvent extends WalletEvent {
  final double amount;
  final String accountNumber;

  const RequestPayoutEvent({required this.amount, required this.accountNumber});

  @override
  List<Object> get props => [amount, accountNumber];
}
