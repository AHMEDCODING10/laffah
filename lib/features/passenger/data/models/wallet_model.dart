import '../../domain/entities/wallet_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.type,
    required super.title,
    required super.date,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'].toString(),
      amount: (json['amount'] ?? 0).toDouble(),
      type: json['type'] ?? 'debit',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'title': title,
      'date': date,
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
      'transactions': (transactions as List<TransactionModel>).map((e) => e.toJson()).toList(),
    };
  }
}
