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
    final titleStr = json['title'] as String? ??
        json['description'] as String? ??
        'معاملة مالية';

    final isPositiveOverride = titleStr.contains('شحن') ||
        titleStr.contains('إيداع') ||
        titleStr.contains('ايداع') ||
        titleStr.contains('مكافأة') ||
        titleStr.contains('مكافاه') ||
        titleStr.contains('بونص') ||
        typeStr == 'deposit' ||
        typeStr == 'credit' ||
        typeStr == 'bonus' ||
        typeStr == 'tripEarnings';

    final isNegativeCalculated = typeStr == 'withdrawal' ||
        typeStr == 'payout' ||
        typeStr == 'deduction' ||
        typeStr == 'commission' ||
        titleStr.contains('عمولة') ||
        titleStr.contains('سحب') ||
        titleStr.contains('خصم');

    final isNegative = isPositiveOverride
        ? false
        : (json['isNegative'] as bool? ??
            json['is_negative'] as bool? ??
            isNegativeCalculated);

    return CaptainTransactionModel(
      id: json['id']?.toString() ?? '',
      type: _parseTransactionType(typeStr, titleStr),
      title: titleStr,
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

  static TransactionType _parseTransactionType(
      String? typeStr, String titleStr) {
    if (typeStr == 'payout' || typeStr == 'withdrawal' || titleStr.contains('سحب')) {
      return TransactionType.payout;
    }
    if (typeStr == 'deposit' || titleStr.contains('شحن') || titleStr.contains('إيداع')) {
      return TransactionType.deposit;
    }
    if (typeStr == 'bonus' || titleStr.contains('مكافأة') || titleStr.contains('بونص')) {
      return TransactionType.bonus;
    }
    if (typeStr == 'commission' || typeStr == 'deduction' || titleStr.contains('عمولة')) {
      return TransactionType.deduction;
    }
    if (typeStr == 'tripEarnings' || titleStr.contains('مشوار') || titleStr.contains('رحلة')) {
      return TransactionType.tripEarnings;
    }
    return TransactionType.adjustment;
  }
}
