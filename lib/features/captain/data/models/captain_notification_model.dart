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
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timeTag: json['timeTag'] as String? ?? '',
      icon: json['icon'] as String? ?? 'bell',
      isRead: json['isRead'] as bool? ?? false,
      type: json['type'] as String? ?? 'alert',
    );
  }
}
