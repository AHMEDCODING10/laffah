import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/services/firebase_notification_service.dart';
import '../models/notification_item_model.dart';

/// Local data source to persist and manage passenger notifications locally,
/// ensuring instant alerts such as trip cancellation appear immediately.
class PassengerNotificationLocalDataSource {
  static const String _storageKey = 'cached_passenger_notifications_v1';

  static Future<List<NotificationItemModel>> getLocalNotifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      if (raw == null || raw.isEmpty) return [];
      final List<dynamic> list = jsonDecode(raw);
      return list
          .map((e) => NotificationItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error getting local notifications: $e");
      return [];
    }
  }

  static Future<void> saveNotification(NotificationItemModel item) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getLocalNotifications();
      existing.removeWhere((n) => n.id == item.id);
      existing.insert(0, item);
      if (existing.length > 50) {
        existing.removeRange(50, existing.length);
      }
      final raw = jsonEncode(existing.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error saving notification: $e");
    }
  }

  static Future<void> deleteNotification(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getLocalNotifications();
      existing.removeWhere((n) => n.id == id);
      final raw = jsonEncode(existing.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error deleting notification: $e");
    }
  }

  static Future<void> markAsRead(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getLocalNotifications();
      final index = existing.indexWhere((n) => n.id == id);
      if (index != -1) {
        final old = existing[index];
        existing[index] = NotificationItemModel(
          id: old.id,
          title: old.title,
          message: old.message,
          time: old.time,
          category: old.category,
          isUnread: false,
          captainName: old.captainName,
          tripId: old.tripId,
          type: old.type,
        );
        final raw = jsonEncode(existing.map((e) => e.toJson()).toList());
        await prefs.setString(_storageKey, raw);
      }
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error marking notification as read: $e");
    }
  }

  static Future<void> markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = await getLocalNotifications();
      final updated = existing
          .map((old) => NotificationItemModel(
                id: old.id,
                title: old.title,
                message: old.message,
                time: old.time,
                category: old.category,
                isUnread: false,
                captainName: old.captainName,
                tripId: old.tripId,
                type: old.type,
              ))
          .toList();
      final raw = jsonEncode(updated.map((e) => e.toJson()).toList());
      await prefs.setString(_storageKey, raw);
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error marking all as read: $e");
    }
  }

  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_storageKey);
    } catch (e) {
      debugPrint("⚠️ [NotificationLocalDataSource] Error clearing notifications: $e");
    }
  }

  /// High-level helper to trigger a cancellation notification both locally and as a device banner
  static Future<void> addTripCancelledNotification({
    required String captainName,
    String? tripId,
    String? reason,
    bool isCancelledByCaptain = false,
  }) async {
    final title = isCancelledByCaptain ? 'ألغى الكابتن المشوار ❌' : 'تم إلغاء المشوار ❌';
    final cleanCaptainName = (captainName.isNotEmpty && captainName != 'قيد البحث')
        ? captainName
        : 'الكابتن';
    final message = isCancelledByCaptain
        ? 'قام الكابتن $cleanCaptainName بإلغاء المشوار${reason != null && reason.isNotEmpty ? " (السبب: $reason)" : ""}. نعتذر منك، يمكنك طلب مشوار جديد الآن.'
        : 'تم إلغاء مشوارك مع الكابتن $cleanCaptainName بنجاح${reason != null && reason.isNotEmpty ? " (السبب: $reason)" : ""}.';

    final notif = NotificationItemModel(
      id: 'cancel_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      time: 'الآن',
      category: 'rides',
      isUnread: true,
      captainName: cleanCaptainName,
      tripId: tripId,
      type: 'trip_cancelled',
    );

    await saveNotification(notif);

    // Show device notification banner with sound & vibration
    FirebaseNotificationService().showNotificationBanner(
      title: title,
      body: message,
      isUrgent: true,
    );
  }
}
