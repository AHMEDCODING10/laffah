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
    final typeStr = json['type'] as String?;
    final isNegative = json['isNegative'] as bool? ??
        json['is_negative'] as bool? ??
        (typeStr == 'withdrawal' ||
            typeStr == 'payout' ||
            typeStr == 'deduction' ||
            typeStr == 'commission');

    return CaptainTransactionModel(
      id: json['id']?.toString() ?? '',
      type: _parseTransactionType(typeStr),
      title: json['title'] as String? ??
          json['description'] as String? ??
          'معاملة مالية',
      date: json['date'] as String? ??
          json['created_at'] as String? ??
          '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'مكتمل',
      isNegative: isNegative,
      refId: json['refId'] as String? ??
          json['ref_id'] as String? ??
          json['reference_id'] as String? ??
          '',
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
