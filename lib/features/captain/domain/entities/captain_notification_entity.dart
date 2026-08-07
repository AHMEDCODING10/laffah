import 'package:equatable/equatable.dart';

class CaptainNotificationEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String timeTag;
  final String icon;
  final bool isRead;
  final String type; // 'system', 'alert', 'promotion', etc.

  const CaptainNotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.timeTag,
    required this.icon,
    required this.isRead,
    required this.type,
  });

  @override
  List<Object?> get props => [id, title, description, timeTag, icon, isRead, type];

  CaptainNotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? timeTag,
    String? icon,
    bool? isRead,
    String? type,
  }) {
    return CaptainNotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      timeTag: timeTag ?? this.timeTag,
      icon: icon ?? this.icon,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
