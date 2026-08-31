extension TripStatusExtension on String {
  String toArabicStatus() {
    switch (toLowerCase().trim()) {
      case 'pending':
        return 'قيد الانتظار';
      case 'accepted':
        return 'تم القبول';
      case 'arrived':
        return 'وصل الكابتن';
      case 'in_transit':
      case 'started':
        return 'في الطريق للوجهة';
      case 'completed':
      case 'delivered':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغي';
      case 'scheduled':
        return 'مجدول';
      case 'arrived_at_pickup':
        return 'وصل لموقع الاستلام';
      case 'picked_up':
        return 'تم الاستلام';
      default:
        return this;
    }
  }
}
