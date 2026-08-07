class NotificationItemModel {
  final String id;
  final String title;
  final String message;
  final String time;
  final String category; // 'trip', 'wallet', 'system'
  final bool isUnread;
  final String? captainName;

  NotificationItemModel({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.category,
    this.isUnread = false,
    this.captainName,
  });

  factory NotificationItemModel.fromJson(Map<String, dynamic> json) {
    return NotificationItemModel(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      time: json['time'] ?? '',
      category: json['category'] ?? 'system',
      isUnread: json['isUnread'] ?? false,
      captainName: json['captainName'],
    );
  }
}
