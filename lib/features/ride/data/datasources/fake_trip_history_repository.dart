/// FakeTripHistoryRepository — Isolates mock data for passenger trip history.
/// Prepared for future REST API integration with Laravel backend.
class FakeTripHistoryRepository {
  FakeTripHistoryRepository._();

  static List<Map<String, dynamic>> getActiveTrips() {
    return [
      {
        'id': 'active_1',
        'type': 'رحلة سريعة',
        'statusAr': 'في الطريق',
        'captainName': 'محمد علي',
        'vehicleModel': 'تويوتا كورولا',
        'vehiclePlate': '2022 • أبيض',
        'pickup': 'شارع حدة، أمام مركز الكميم',
        'dropoff': 'حي النهضة، شارع الستين',
        'captainImg': 'assets/images/captain_1.png',
        'isRide': true,
      },
      {
        'id': 'active_2',
        'type': 'إرسال طرد',
        'statusAr': 'جاري البحث عن كابتن',
        'orderNumber': 'رقم الطلب #LFX-782',
        'parcelContent': 'أوراق ومستندات رسمية',
        'isRide': false,
      }
    ];
  }

  static List<Map<String, dynamic>> getScheduledTrips() {
    return [
      {
        'id': 'scheduled_1',
        'type': 'رحلة مجدولة',
        'time': 'غداً، 08:00 ص',
        'pickup': 'بيت بوس، شارع الخمسين',
        'dropoff': 'مطار صنعاء الدولي',
        'vehicleType': 'سيارة لَفَّة سريع',
        'estimatedFare': 2400.0,
      }
    ];
  }

  static List<Map<String, dynamic>> getPastTrips() {
    return [
      {
        'id': 'past_1',
        'type': 'رحلة سريعة',
        'date': '12 أكتوبر 2025 • 10:30 ص',
        'captainName': 'أحمد محمد',
        'vehicleModel': 'تويوتا كورولا',
        'vehiclePlate': '77213',
        'pickup': 'صنعاء مول، شارع حدة',
        'dropoff': 'شارع الزبيري، برج التسهيلات',
        'fare': 1200.0,
        'isRide': true,
      },
      {
        'id': 'past_2',
        'type': 'توصيل طرد',
        'date': '09 أكتوبر 2025 • 03:45 م',
        'captainName': 'أحمد منصور',
        'vehicleModel': 'دراجة نارية (كاديلات)',
        'vehiclePlate': '99432',
        'pickup': 'بيت بوس، صنعاء',
        'dropoff': 'شارع الستين، صنعاء',
        'fare': 800.0,
        'isRide': false,
      },
      {
        'id': 'past_3',
        'type': 'رحلة سريعة',
        'date': '08 أكتوبر 2025 • 09:00 ص',
        'captainName': 'محمد الغيلي',
        'vehicleModel': 'سوزوكي سويفت',
        'vehiclePlate': '12894',
        'pickup': 'جامعة صنعاء، البوابة الغربية',
        'dropoff': 'مركز الكميم، شارع حدة',
        'fare': 1500.0,
        'isRide': true,
      },
    ];
  }

  static List<Map<String, dynamic>> getCancelledTrips() {
    return [
      {
        'id': 'cancelled_1',
        'type': 'رحلة سريعة',
        'date': '05 أكتوبر 2025 • 06:15 م',
        'reason': 'تم الإلغاء بواسطة الراكب (تأخر الكابتن)',
        'pickup': 'شارع حدة، صنعاء',
        'dropoff': 'حي الأصبحي، صنعاء',
        'isRide': true,
      }
    ];
  }
}
