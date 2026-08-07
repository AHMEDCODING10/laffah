import 'package:equatable/equatable.dart';

enum TransactionType {
  tripEarnings,
  payout,
  bonus,
  adjustment
}

class CaptainTransactionEntity extends Equatable {
  final String id;
  final TransactionType type;
  final String title;
  final String date;
  final double amount;
  final String status;
  final bool isNegative;
  final String refId;

  const CaptainTransactionEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.date,
    required this.amount,
    required this.status,
    required this.isNegative,
    required this.refId,
  });

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        date,
        amount,
        status,
        isNegative,
        refId,
      ];
}
