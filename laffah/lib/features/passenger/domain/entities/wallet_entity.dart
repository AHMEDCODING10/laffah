import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final double amount;
  final String type; // 'credit', 'debit', 'deposit', etc.
  final String title;
  final String date;
  final String status; // 'pending', 'completed', 'rejected'
  final String? referenceId;
  final String? paymentMethod;
  final String? senderAccount;

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.title,
    required this.date,
    this.status = 'completed',
    this.referenceId,
    this.paymentMethod,
    this.senderAccount,
  });

  /// Check whether the transaction represents an incoming credit (top-up, deposit, bonus, refund)
  bool get isCredit {
    final t = type.toLowerCase().trim();
    if (t == 'credit' ||
        t == 'deposit' ||
        t == 'recharge' ||
        t == 'top_up' ||
        t == 'topup' ||
        t == 'refund' ||
        t == 'bonus' ||
        t == 'cashback') {
      return true;
    }
    if (t == 'debit' ||
        t == 'trip' ||
        t == 'trip_payment' ||
        t == 'ride' ||
        t == 'withdrawal' ||
        t == 'fee' ||
        t == 'deduction') {
      return false;
    }
    // Content inspection for Arabic transactions
    final lowerTitle = title.toLowerCase();
    if (lowerTitle.contains('شحن') ||
        lowerTitle.contains('إيداع') ||
        lowerTitle.contains('ايداع') ||
        lowerTitle.contains('مكافأة') ||
        lowerTitle.contains('مكافاه') ||
        lowerTitle.contains('استرداد') ||
        lowerTitle.contains('إضافة') ||
        lowerTitle.contains('اضافة')) {
      return true;
    }
    return false;
  }

  /// Status checks
  bool get isPending {
    final s = status.toLowerCase();
    return s == 'pending' ||
        s == 'قيد المراجعة' ||
        s == 'معلق' ||
        title.contains('قيد المراجعة') ||
        title.contains('معلق');
  }

  bool get isRejected {
    final s = status.toLowerCase();
    return s == 'rejected' ||
        s == 'cancelled' ||
        s == 'مرفوض' ||
        s == 'ملغي' ||
        title.contains('مرفوض') ||
        title.contains('ملغي');
  }

  bool get isCompleted => !isPending && !isRejected;

  /// Structured display title (Clean like Uber)
  String get displayTitle {
    final t = title;
    if (t.contains('شحن') || t.contains('إيداع') || isCredit) {
      if (t.contains('جيب')) return 'شحن عبر محفظة جيب';
      if (t.contains('الكريمي')) return 'شحن عبر بنك الكريمي';
      if (t.contains('جوالي') || t.contains('WeCash')) return 'شحن عبر جوالي (WeCash)';
      if (t.contains('ون كاش') || t.contains('OneCash')) return 'شحن عبر ون كاش';
      if (t.contains('التضامن') || t.contains('محفظتي')) return 'شحن عبر محفظتي (التضامن)';
      if (t.contains('كاك')) return 'شحن عبر كاك بنك';
      return 'شحن رصيد المحفظة';
    }
    if (t.contains('مشوار') || t.contains('رحلة') || !isCredit) {
      return 'أجرة مشوار لَفَّة';
    }
    if (t.contains('استرداد')) {
      return 'استرداد رصيد مشوار';
    }
    return t.isNotEmpty ? t : 'معاملة مالية';
  }

  /// Structured subtitle (e.g. "محفظة جيب • سند #874773")
  String get displaySubtitle {
    final ref = extractedReferenceId;
    final method = extractedPaymentMethod;
    final parts = <String>[];

    if (method != null && method.isNotEmpty) {
      parts.add(method);
    }
    if (ref != null && ref.isNotEmpty) {
      parts.add('سند #$ref');
    }
    if (parts.isEmpty && date.isNotEmpty) {
      parts.add(date);
    }
    return parts.join(' • ');
  }

  String? get extractedReferenceId {
    if (referenceId != null && referenceId!.isNotEmpty) {
      return referenceId;
    }
    final match = RegExp(r'رقم السند:\s*([^\s\-\)]+)').firstMatch(title);
    if (match != null) {
      return match.group(1);
    }
    final matchRef = RegExp(r'مرجع:\s*([^\s\-\)]+)').firstMatch(title);
    return matchRef?.group(1);
  }

  String? get extractedSenderAccount {
    if (senderAccount != null && senderAccount!.isNotEmpty) {
      return senderAccount;
    }
    final match = RegExp(r'من حساب:\s*([^\s\-\)]+)').firstMatch(title);
    return match?.group(1);
  }

  String? get extractedPaymentMethod {
    if (paymentMethod != null && paymentMethod!.isNotEmpty) {
      return paymentMethod;
    }
    if (title.contains('جيب')) return 'محفظة جيب (اليمن والبحرين)';
    if (title.contains('الكريمي')) return 'الكريمي (حاسب / إم فلوس)';
    if (title.contains('جوالي') || title.contains('WeCash')) return 'جوالي (WeCash)';
    if (title.contains('ون كاش') || title.contains('OneCash')) return 'ون كاش (OneCash)';
    if (title.contains('التضامن')) return 'محفظتي (بنك التضامن)';
    if (title.contains('كاك')) return 'كاك بنك (السريع)';
    return null;
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        type,
        title,
        date,
        status,
        referenceId,
        paymentMethod,
        senderAccount,
      ];
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
