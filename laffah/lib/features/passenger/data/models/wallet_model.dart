import '../../domain/entities/wallet_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.title,
    required super.date,
    super.status,
    super.referenceId,
    super.paymentMethod,
    super.senderAccount,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final rawType = json['type']?.toString().trim() ?? '';
    final rawTitle = json['title']?.toString() ??
        json['description']?.toString() ??
        '';

    final rawStatus = json['status']?.toString() ??
        (rawTitle.contains('قيد المراجعة')
            ? 'pending'
            : rawTitle.contains('مرفوض')
                ? 'rejected'
                : 'completed');

    final refId = json['reference_id']?.toString() ??
        json['ref_id']?.toString() ??
        json['reference']?.toString();

    final method =
        json['payment_method']?.toString() ?? json['method']?.toString();
    final senderAcc = json['sender_account']?.toString() ??
        json['from_account']?.toString();

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      type: rawType.isNotEmpty
          ? rawType
          : (rawTitle.contains('شحن') || rawTitle.contains('إيداع')
              ? 'deposit'
              : 'debit'),
      title: rawTitle,
      date: json['date']?.toString() ??
          json['created_at']?.toString() ??
          '',
      status: rawStatus,
      referenceId: refId,
      paymentMethod: method,
      senderAccount: senderAcc,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'title': title,
      'date': date,
      'status': status,
      'reference_id': referenceId,
      'payment_method': paymentMethod,
      'sender_account': senderAccount,
    };
  }
}

class WalletModel extends WalletEntity {
  const WalletModel({
    required super.balance,
    required List<TransactionModel> super.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final list = json['transactions'] as List? ?? [];
    final parsedTx = list.map((e) => TransactionModel.fromJson(e)).toList();

    return WalletModel(
      balance: (json['balance'] ?? 0).toDouble(),
      transactions: parsedTx,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'transactions': (transactions as List<TransactionModel>)
          .map((e) => e.toJson())
          .toList(),
    };
  }
}
