import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../network/dio_client.dart';
import '../network/api_endpoints.dart';
import '../di/injection_container.dart' as di;

/// Top-level background message handler for FCM
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("🔔 [FCM Background] Received message: ${message.messageId} - ${message.notification?.title}");
}

class FirebaseNotificationService {
  static final FirebaseNotificationService _instance = FirebaseNotificationService._internal();
  factory FirebaseNotificationService() => _instance;
  FirebaseNotificationService._internal();

  FirebaseMessaging? _messaging;
  FlutterLocalNotificationsPlugin? _localNotifications;

  /// Default notification channel for general updates (offers, system, messages)
  static const AndroidNotificationChannel _defaultChannel = AndroidNotificationChannel(
    'laffah_general_channel',
    'Laffah General Notifications',
    description: 'General updates, promotions and news from Laffah',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// High priority alarm channel for new ride requests, trip assignments and emergency alerts
  static const AndroidNotificationChannel _tripAlertChannel = AndroidNotificationChannel(
    'laffah_trip_alerts_channel',
    'Laffah Trip Requests & Alerts',
    description: 'High-priority ride requests and live trip status alerts with persistent sound and vibration',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  bool _isInitialized = false;

  /// Initialize Firebase Cloud Messaging and Local Notifications
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (Firebase.apps.isEmpty) {
      debugPrint("ℹ️ [FCM] Firebase App is not initialized. Skipping notification setup.");
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;
      _messaging = messaging;
      _localNotifications = FlutterLocalNotificationsPlugin();
      // 1. Set background messaging handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // 2. Request user permissions (iOS & Android 13+)
      await _requestPermission();

      // 3. Setup Local Notifications for Foreground display on Android
      await _setupLocalNotifications();

      // 4. Listen to token refresh
      messaging.onTokenRefresh.listen((newToken) {
        debugPrint("🔄 [FCM] Token refreshed: $newToken");
        syncTokenWithBackend(newToken);
      });

      // 5. Handle Foreground Messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // 6. Handle Background Notification Click
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationClick);

      // 7. Check if app was opened from a Terminated state by clicking notification
      final initialMessage = await messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleNotificationClick(initialMessage);
      }

      _isInitialized = true;
      debugPrint("✅ [FCM] Firebase Notification Service successfully initialized!");
    } catch (e) {
      debugPrint("⚠️ [FCM] Initialization error: $e");
    }
  }

  /// Request iOS and Android 13+ Notification Permissions
  Future<void> _requestPermission() async {
    if (_messaging == null) return;
    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      criticalAlert: true,
    );

    debugPrint("🔔 [FCM] User authorization status: ${settings.authorizationStatus}");

    // Set foreground notification presentation options for Apple
    await _messaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  /// Setup local notifications for Android foreground heads-up notifications
  Future<void> _setupLocalNotifications() async {
    if (_localNotifications == null) return;
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications!.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint("🔔 [LocalNotification] Tapped notification payload: ${response.payload}");
      },
    );

    // Create both notification channels on Android
    final androidPlugin = _localNotifications!.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(_defaultChannel);
      await androidPlugin.createNotificationChannel(_tripAlertChannel);
    }
  }

  /// Display heads-up banner when notification arrives in Foreground
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint("🔔 [FCM Foreground] Title: ${message.notification?.title}, Body: ${message.notification?.body}");

    final notification = message.notification;
    final android = message.notification?.android;
    final type = message.data['type'] ?? '';
    final isTripAlert = type == 'trip_new' || type == 'trip_accepted' || type == 'trip_arrived';

    if (notification != null && !kIsWeb && _localNotifications != null) {
      final selectedChannel = isTripAlert ? _tripAlertChannel : _defaultChannel;

      await _localNotifications!.show(
        notification.hashCode,
        notification.title ?? 'لَفَّة',
        notification.body ?? '',
        NotificationDetails(
          android: AndroidNotificationDetails(
            selectedChannel.id,
            selectedChannel.name,
            channelDescription: selectedChannel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: selectedChannel.importance,
            priority: isTripAlert ? Priority.max : Priority.high,
            playSound: true,
            enableVibration: true,
            category: isTripAlert ? AndroidNotificationCategory.call : AndroidNotificationCategory.message,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: message.data.toString(),
      );
    }
  }

  /// Handle user clicking on a notification banner
  void _handleNotificationClick(RemoteMessage message) {
    debugPrint("🚀 [FCM Action] User clicked notification: ${message.data}");
    final type = message.data['type'];
    final tripId = message.data['trip_id'];

    if (tripId != null) {
      debugPrint("🚕 [FCM Navigation] Trip related notification for trip ID: $tripId (Type: $type)");
    }
  }

  /// Get current FCM Token
  Future<String?> getToken() async {
    if (Firebase.apps.isEmpty || _messaging == null) return null;
    try {
      return await _messaging!.getToken();
    } catch (e) {
      debugPrint("⚠️ [FCM] Failed to get token: $e");
      return null;
    }
  }

  /// Subscribe to a specific topic (e.g. 'all_captains', 'all_passengers')
  Future<void> subscribeToTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging!.subscribeToTopic(topic);
      debugPrint("✅ [FCM] Subscribed to topic: $topic");
    } catch (e) {
      debugPrint("⚠️ [FCM] Failed to subscribe to topic $topic: $e");
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (_messaging == null) return;
    try {
      await _messaging!.unsubscribeFromTopic(topic);
      debugPrint("✅ [FCM] Unsubscribed from topic: $topic");
    } catch (e) {
      debugPrint("⚠️ [FCM] Failed to unsubscribe from topic $topic: $e");
    }
  }

  /// Sync FCM token with Laravel backend
  Future<void> syncTokenWithBackend([String? token]) async {
    if (Firebase.apps.isEmpty) return;
    try {
      final fcmToken = token ?? await getToken();
      if (fcmToken == null || fcmToken.isEmpty) return;

      debugPrint("📤 [FCM] Sending token to backend: $fcmToken");

      // Check if DioClient is registered and send update
      if (di.sl.isRegistered<DioClient>()) {
        final dioClient = di.sl<DioClient>();
        await dioClient.dio.post(
          ApiEndpoints.updateProfile,
          data: {'fcm_token': fcmToken},
        );
        debugPrint("✅ [FCM] Token synchronized with backend successfully!");
      }
    } catch (e) {
      debugPrint("⚠️ [FCM] Failed to sync token with backend: $e");
    }
  }
}