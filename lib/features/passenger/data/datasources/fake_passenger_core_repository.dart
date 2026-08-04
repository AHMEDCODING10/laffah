import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Notification Category Enum
enum NotificationCategory { rides, parcels, messages, offers }

/// Notification Data Model
class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final NotificationCategory category;
  final IconData? icon;
  final Color? color;
  final String? captainName;
  final bool isUnread;
  final bool isToday;
  final String? routePath;

  const NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.icon,
    this.color,
    this.captainName,
    this.isUnread = false,
    this.isToday = true,
    this.routePath,
  });
}

/// Wallet Transaction Data Model
class WalletTransactionModel {
  final String id;
  final String title;
  final String subtitle;
  final String date;
  final double amount;
  final bool isDeposit;
  final IconData icon;

  const WalletTransactionModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.amount,
    required this.isDeposit,
    required this.icon,
  });
}

/// Promo Voucher Data Model
class PromoVoucherModel {
  final String id;
  final String code;
  final String discountTitle;
  final String description;
  final String expiryDate;
  final bool isUsed;

  const PromoVoucherModel({
    required this.id,
    required this.code,
    required this.discountTitle,
    required this.description,
    required this.expiryDate,
    this.isUsed = false,
  });
}

/// FakePassengerCoreRepository — Isolates mock data for passenger notifications, wallet, and promos.
/// Prepared for REST API integration with Laravel backend.
class FakePassengerCoreRepository {
  FakePassengerCoreRepository._();

  static List<NotificationItemModel> getNotifications() {
    return const [
      NotificationItemModel(
        id: 'r1',
        title: 'وصول الكابتن',
        message: 'الكابتن أحمد محمد وصل الآن إلى موقع الانطلاق وبانتظارك.',
        time: 'منذ ٥ دقائق',
        category: NotificationCategory.rides,
        icon: Icons.directions_car_filled_rounded,
        color: AppColors.primary500,
        isUnread: true,
        isToday: true,
      ),
      NotificationItemModel(
        id: 'r2',
        title: 'رحلتك اكتملت بنجاح',
        message: 'نأمل أن تكون قد استمتعت برحلتك مع الكابتن محمد علي. لا تنسَ التقييم!',
        time: 'منذ ساعتين',
        category: NotificationCategory.rides,
        icon: Icons.check_circle_rounded,
        color: AppColors.success,
        isUnread: false,
        isToday: true,
      ),
      NotificationItemModel(
        id: 'p1',
        title: 'تسليم طرد بنجاح',
        message: 'تم توثيق تسليم الطرد رقم #LFX-782 بواسطة الكابتن وتوقيع المستلم.',
        time: 'منذ ٤٥ دقيقة',
        category: NotificationCategory.parcels,
        icon: Icons.all_inbox_rounded,
        color: AppColors.info,
        isUnread: true,
        isToday: true,
      ),
      NotificationItemModel(
        id: 'm1',
        title: 'رسالة جديدة من الكابتن',
        message: 'أنا عند البوابة الرئيسية، أين أنت تحديداً؟',
        time: 'منذ ١٥ دقيقة',
        category: NotificationCategory.messages,
        icon: Icons.chat_bubble_rounded,
        color: AppColors.warning,
        captainName: 'الكابتن خالد',
        isUnread: true,
        isToday: true,
      ),
      NotificationItemModel(
        id: 'o1',
        title: 'خصم خاص ٢٠٪ على رحلتك القادمة!',
        message: 'استخدم الكود LAFFAH20 واحصل على خصم فوري يصل إلى ٥٠٠ ريال.',
        time: 'منذ ٣ ساعات',
        category: NotificationCategory.offers,
        icon: Icons.local_offer_rounded,
        color: AppColors.primary500,
        isUnread: false,
        isToday: true,
      ),
    ];
  }

  static double getWalletBalance() => 4500.0;

  static List<WalletTransactionModel> getWalletTransactions() {
    return const [
      WalletTransactionModel(
        id: 'tx_1',
        title: 'شحن رصيد عبر بنك الكريمي',
        subtitle: 'رقم العملية #KR-98214',
        date: 'اليوم، 10:15 ص',
        amount: 5000.0,
        isDeposit: true,
        icon: Icons.account_balance_wallet_rounded,
      ),
      WalletTransactionModel(
        id: 'tx_2',
        title: 'خصم أجرة مشوار',
        subtitle: 'من شارع حدة إلى شارع الستين',
        date: 'أمس، 06:30 م',
        amount: 1500.0,
        isDeposit: false,
        icon: Icons.directions_car_filled_rounded,
      ),
      WalletTransactionModel(
        id: 'tx_3',
        title: 'خصم رسوم توصيل طرد',
        subtitle: 'طرد مستندات #LFX-782',
        date: '01 نوفمبر 2025',
        amount: 1000.0,
        isDeposit: false,
        icon: Icons.inventory_2_rounded,
      ),
    ];
  }

  static List<PromoVoucherModel> getPromoVouchers() {
    return const [
      PromoVoucherModel(
        id: 'promo_1',
        code: 'LAFFAH20',
        discountTitle: 'خصم 20% على مشوارك القادم',
        description: 'ينطبق على الرحلات السريعة بداخل صنعاء، حتى 500 ريال.',
        expiryDate: 'ينتهي في 15 نوفمبر 2025',
      ),
      PromoVoucherModel(
        id: 'promo_2',
        code: 'FREEPARCEL',
        discountTitle: 'توصيل طرد مجاني الأول',
        description: 'خصم 100% على أول طلب إرسال طرد للعملاء الجدد.',
        expiryDate: 'ينتهي في 30 نوفمبر 2025',
      ),
    ];
  }
}
