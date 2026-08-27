import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String type; // 'credit', 'debit'
  final String title;
  final String date;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.title,
    required this.date,
  });

  @override
  List<Object?> get props => [id, amount, type, title, date];
}

class WalletEntity extends Equatable {
  final double balance;
  final List<TransactionEntity> transactions;

  const WalletEntity({
    required this.balance,
    required this.transactions,
  });

  @override
  List<Object?> get props => [balance, transactions];
}
