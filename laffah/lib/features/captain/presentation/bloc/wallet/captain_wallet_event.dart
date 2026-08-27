import 'package:equatable/equatable.dart';

abstract class CaptainWalletEvent extends Equatable {
  const CaptainWalletEvent();

  @override
  List<Object> get props => [];
}

class FetchWalletDetails extends CaptainWalletEvent {}

class RequestPayoutEvent extends CaptainWalletEvent {
  final double amount;
  final String method;
  final String accountNumber;

  const RequestPayoutEvent({
    required this.amount,
    required this.method,
    required this.accountNumber,
  });

  @override
  List<Object> get props => [amount, method, accountNumber];
}
