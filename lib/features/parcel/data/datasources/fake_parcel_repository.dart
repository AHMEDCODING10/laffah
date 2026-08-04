/// FakeParcelRepository — Isolates mock data for parcel tracking and delivery history.
/// Prepared for future REST API integration with Laravel backend.
class FakeParcelRepository {
  FakeParcelRepository._();

  static Map<String, dynamic> getMockTrackingDetails(String trackingId) {
    return {
      'trackingId': trackingId.isEmpty ? 'LFX-982415' : trackingId,
      'statusAr': 'في الطريق إلى المستلم',
      'senderName': 'سارة العامري',
      'senderPhone': '+967 777 123 456',
      'receiverName': 'علي عبدالله',
      'receiverPhone': '+967 773 987 654',
      'pickupLocation': 'شارع حدة، أمام مركز الكميم',
      'dropoffLocation': 'شارع الستين، بالقرب من مستشفى المغامرة',
      'parcelType': 'مستندات وأوراق رسمية',
      'captainName': 'خالد المنصوري',
      'captainPhone': '+967 771 555 333',
      'vehicleModel': 'دراجة نارية هوك 2024',
      'vehiclePlate': '14829 - صنعاء',
      'price': 1500.0,
      'isInsured': true,
      'estimatedArrival': '15 دقيقة',
    };
  }

  static List<Map<String, dynamic>> getParcelHistoryList() {
    return [
      {
        'id': 'LFX-982415',
        'receiverName': 'علي عبدالله',
        'parcelType': 'مستندات وأوراق رسمية',
        'statusAr': 'قيد التوصيل',
        'date': 'اليوم، 02:30 م',
        'price': 1500.0,
      },
      {
        'id': 'LFX-812304',
        'receiverName': 'فاطمة المحرمي',
        'parcelType': 'إلكترونيات وأجهزة',
        'statusAr': 'تم التسليم بنجاح',
        'date': 'أمس، 11:15 ص',
        'price': 2500.0,
      },
    ];
  }
}
