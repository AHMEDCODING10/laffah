class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'rides', 'parcels', 'messages', 'offers', 'system'
  final bool isUnread;
  final String? captainName;
  final String? tripId;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.isUnread = false,
    this.captainName,
    this.tripId,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    // Map backend type to category
    String rawType = json['type'] ?? json['category'] ?? 'system';
    String category = 'system';
    if (rawType.contains('trip') || rawType == 'rides') {
      category = 'rides';
    } else if (rawType.contains('parcel') || rawType == 'parcels') {
      category = 'parcels';
    } else if (rawType.contains('message') || rawType == 'messages') {
      category = 'messages';
    } else if (rawType.contains('promo') || rawType == 'offers') {
      category = 'offers';
    }

    final bool isRead = json['isRead'] == true ||
        json['is_read'] == true ||
        (json['read_at'] != null);

    return NotificationItemModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      message: json['description'] ?? json['message'] ?? '',
      time: json['timeTag'] ?? json['time_tag'] ?? json['time'] ?? 'الآن',
      category: category,
      isUnread: !isRead,
      captainName: json['captainName'] ?? json['extra']?['captain_name'],
      tripId: json['tripId']?.toString() ?? json['trip_id']?.toString(),
    );
  }
}
