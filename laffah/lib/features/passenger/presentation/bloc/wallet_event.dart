import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class GetWalletBalanceEvent extends WalletEvent {}

class GetCompanyAccountsEvent extends WalletEvent {}

class RechargeWalletEvent extends WalletEvent {
  final double amount;
  final String paymentMethod;
  final String referenceId;
  final String? senderAccount;

  const RechargeWalletEvent({
    required this.amount,
    required this.paymentMethod,
    required this.referenceId,
    this.senderAccount,
  });

  @override
  List<Object?> get props => [amount, paymentMethod, referenceId, senderAccount];
}

class RequestPayoutEvent extends WalletEvent {
  final double amount;
  final String accountNumber;

  const RequestPayoutEvent({required this.amount, required this.accountNumber});

  @override
  List<Object?> get props => [amount, accountNumber];
}

class ResetWalletEvent extends WalletEvent {
  const ResetWalletEvent();
}
