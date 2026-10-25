import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../network/dio_client.dart';

class OfflineQueueService {
  final SharedPreferences prefs;
  final DioClient dioClient;

  static const String _queueKey = 'offline_trip_status_queue';

  OfflineQueueService({required this.prefs, required this.dioClient});

  /// Add a trip status update to the offline queue
  Future<void> enqueueTripStatusUpdate(String tripId, String status) async {
    try {
      final List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];
      final Map<String, dynamic> newTask = {
        'tripId': tripId,
        'status': status,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      currentQueue.add(jsonEncode(newTask));
      await prefs.setStringList(_queueKey, currentQueue);
      debugPrint('📦 [OfflineQueue] Enqueued trip update: $tripId -> $status');
    } catch (e) {
      debugPrint('🔴 [OfflineQueue] Failed to enqueue: $e');
    }
  }

  /// Attempt to send all queued updates to the server
  Future<void> syncOfflineQueue() async {
    final List<String> currentQueue = prefs.getStringList(_queueKey) ?? [];
    if (currentQueue.isEmpty) return;

    debugPrint('🔄 [OfflineQueue] Syncing ${currentQueue.length} pending updates...');

    final List<String> remainingQueue = [];

    for (final String taskStr in currentQueue) {
      try {
        final Map<String, dynamic> task = jsonDecode(taskStr);
        final String tripId = task['tripId'];
        final String status = task['status'];

        final response = await dioClient.dio.post(
          '/trips/$tripId/status',
          data: {'status': status},
        );

        if (response.statusCode == 200 || response.data?['status'] == 'success') {
          debugPrint('✅ [OfflineQueue] Synced successfully: $tripId -> $status');
        } else {
          // If server rejects it (not a connection error), we still remove it
          debugPrint('⚠️ [OfflineQueue] Server rejected sync for $tripId');
        }
      } on DioException catch (e) {
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout || 
            e.type == DioExceptionType.unknown) {
          // Network issue, keep in queue
          debugPrint('🌐 [OfflineQueue] Network error, keeping in queue: ${e.message}');
          remainingQueue.add(taskStr);
        } else {
          // 4xx or 5xx error, drop from queue to prevent infinite loops
          debugPrint('❌ [OfflineQueue] Dropping task due to HTTP error: ${e.response?.statusCode}');
        }
      } catch (e) {
        // Drop malformed tasks
        debugPrint('💥 [OfflineQueue] Dropping malformed task: $e');
      }
    }

    await prefs.setStringList(_queueKey, remainingQueue);
  }
}
