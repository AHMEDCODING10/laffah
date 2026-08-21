import '../../domain/entities/captain_notification_entity.dart';

class CaptainNotificationModel extends CaptainNotificationEntity {
  const CaptainNotificationModel({
    required super.id,
    required super.title,
    required super.description,
    required super.timeTag,
    required super.icon,
    required super.isRead,
    required super.type,
  });

  factory CaptainNotificationModel.fromJson(Map<String, dynamic> json) {
    return CaptainNotificationModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String? ?? 'إشعار جديد',
      description: json['description'] as String? ??
          json['body'] as String? ??
          json['message'] as String? ??
          '',
      timeTag: json['timeTag'] as String? ??
          json['time_tag'] as String? ??
          json['created_at'] as String? ??
          'الآن',
      icon: json['icon'] as String? ?? 'bell',
      isRead: json['isRead'] == true ||
          json['is_read'] == true ||
          (json['read_at'] != null),
      type: json['type'] as String? ?? 'alert',
    );
  }
}
