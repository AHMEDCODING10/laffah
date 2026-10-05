import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum TransactionType { tripEarnings, payout, bonus, adjustment, deduction, deposit }

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

  /// Transaction type detectors
  bool get isCommission =>
      title.contains('عمولة') ||
      type == TransactionType.deduction ||
      type == TransactionType.adjustment;

  bool get isParcel =>
      title.contains('طرد') ||
      title.contains('LF-P') ||
      refId.startsWith('LF-P');

  bool get isTrip =>
      title.contains('مشوار') ||
      title.contains('رحلة') ||
      type == TransactionType.tripEarnings;

  bool get isCash =>
      title.contains('نقداً') ||
      title.contains('نقد') ||
      title.contains('كاش');

  bool get isPayout =>
      type == TransactionType.payout ||
      title.contains('سحب') ||
      title.contains('تحويل');

  bool get isDeposit =>
      type == TransactionType.bonus ||
      type == TransactionType.deposit ||
      title.contains('شحن') ||
      title.contains('إيداع') ||
      title.contains('ايداع') ||
      title.contains('مكافأة') ||
      title.contains('بونص');

  /// Clean display title (Uber Driver style)
  String get displayTitle {
    final t = title;
    if (isCommission) {
      if (isParcel) return 'عمولة منصة لَفَّة (توصيل طرد)';
      final tripNumber = extractedRefNumber;
      if (tripNumber.isNotEmpty) return 'عمولة مشوار لَفَّة #$tripNumber';
      return 'عمولة منصة لَفَّة';
    }
    if (isDeposit) {
      if (t.contains('مكافأة') || t.contains('بونص')) return 'مكافأة تحقيق الهدف';
      return 'شحن رصيد المحفظة';
    }
    if (isPayout) {
      return 'طلب سحب أرباح';
    }
    if (isTrip) {
      final tripNumber = extractedRefNumber;
      if (tripNumber.isNotEmpty) return 'أجرة مشوار لَفَّة #$tripNumber';
      return 'أجرة مشوار لَفَّة';
    }
    return t.isNotEmpty ? t : 'معاملة مالية';
  }

  /// Clean display subtitle (Uber Driver style)
  String get displaySubtitle {
    final parts = <String>[];
    if (isCommission) {
      if (isCash) {
        parts.add('استلمت الأجرة كاش باليد');
      } else {
        parts.add('عمولة المشوار للمنصة');
      }
    } else if (isDeposit) {
      parts.add('إيداع وسداد عمولات');
    } else if (isPayout) {
      parts.add('تحويل للمحفظة الإلكترونية');
    } else if (isTrip) {
      if (isCash) {
        parts.add('دفع نقدي من الراكب');
      } else {
        parts.add('دفع إلكتروني بالمحفظة');
      }
    }

    final ref = extractedRefNumber;
    if (ref.isNotEmpty && !parts.any((p) => p.contains(ref))) {
      parts.add('#$ref');
    }

    if (parts.isEmpty && date.isNotEmpty) {
      parts.add(date);
    }

    return parts.join(' • ');
  }

  String get extractedRefNumber {
    if (refId.isNotEmpty) return refId;
    final matchTrip = RegExp(r'#([A-Za-z0-9_\-]+)').firstMatch(title);
    if (matchTrip != null) return matchTrip.group(1)!;
    final matchNum = RegExp(r'رقم\s*([0-9]+)').firstMatch(title);
    if (matchNum != null) return matchNum.group(1)!;
    return '';
  }

  IconData get categoryIcon {
    if (isParcel) return Icons.inventory_2_rounded;
    if (isPayout) return Icons.account_balance_wallet_rounded;
    if (isDeposit) return Icons.add_circle_outline_rounded;
    if (isTrip) return Icons.directions_car_rounded;
    return isNegative ? Icons.remove_circle_outline_rounded : Icons.check_circle_rounded;
  }

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
