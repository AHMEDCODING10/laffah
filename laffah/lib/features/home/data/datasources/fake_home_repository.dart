import 'package:flutter/material.dart';
import '../../../../core/router/app_router.dart';

/// FakeHomeRepository — Isolates mock home data for quick & recent destinations.
/// Prepared for future backend API integration with Laravel.
class FakeHomeRepository {
  FakeHomeRepository._();

  static List<Map<String, dynamic>> getQuickDestinations() {
    return [
      {
        'id': 'saved',
        'title': 'المحفوظة',
        'location': 'المواقع المحفوظة',
        'icon': Icons.bookmark_outline_rounded,
        'route': LaffahRoutes.passengerSavedPlaces,
      },
      {
        'id': 'university',
        'title': 'الجامعة',
        'location': 'جامعة صنعاء - البوابة الرئيسية',
        'icon': Icons.school_outlined,
      },
      {
        'id': 'work',
        'title': 'العمل',
        'location': 'شارع الزبيري - برج الأمل التجاري',
        'icon': Icons.work_outline_rounded,
      },
      {
        'id': 'home',
        'title': 'المنزل',
        'location': 'حي حدة - خلف بريد حدة السكني',
        'icon': Icons.home_outlined,
      },
    ];
  }

  static List<Map<String, dynamic>> getRecentDestinations() {
    return [
      {
        'title': 'مركز الكميم التجاري',
        'subtitle': 'شارع حدة، مقابل بنك اليمن والخليج',
        'distance': '2.4 كم',
        'icon': Icons.storefront_rounded,
      },
      {
        'title': 'بوابة جامعة صنعاء الغربية',
        'subtitle': 'شارع الدائري الغربي، صنعاء',
        'distance': '4.1 كم',
        'icon': Icons.account_balance_rounded,
      },
    ];
  }
}
