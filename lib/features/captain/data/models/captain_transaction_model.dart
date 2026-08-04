import '../../domain/entities/captain_transaction_entity.dart';

class CaptainTransactionModel extends CaptainTransactionEntity {
  const CaptainTransactionModel({
    required super.id,
    required super.type,
    required super.title,
    required super.date,
    required super.amount,
    required super.status,
    required super.isNegative,
    required super.refId,
  });

  factory CaptainTransactionModel.fromJson(Map<String, dynamic> json) {
    return CaptainTransactionModel(
      id: json['id'] as String? ?? '',
      type: _parseTransactionType(json['type'] as String?),
      title: json['title'] as String? ?? 'معاملة',
      date: json['date'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'مكتمل',
      isNegative: json['isNegative'] as bool? ?? false,
      refId: json['refId'] as String? ?? '',
    );
  }

  static TransactionType _parseTransactionType(String? typeStr) {
    switch (typeStr) {
      case 'payout':
      case 'withdrawal':
        return TransactionType.payout;
      case 'tripEarnings':
      case 'deposit':
        return TransactionType.tripEarnings;
      case 'deduction':
      default:
        return TransactionType.adjustment;
    }
  }
}
