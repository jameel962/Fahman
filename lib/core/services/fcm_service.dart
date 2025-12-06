import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// FCM Service for handling Firebase Cloud Messaging
/// Supports both Android and iOS platforms
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    // Request permission for iOS
    await _requestPermissions();

    // Configure local notifications
    await _configureLocalNotifications();

    // Get FCM token
    final token = await getToken();
    print('═══════════════════════════════════════════════════════');
    print('🔔 FCM TOKEN RETRIEVED:');
    print('Token: $token');
    print('Token Length: ${token?.length ?? 0}');
    print('Token Status: ${token != null ? "✅ SUCCESS" : "❌ FAILED"}');
    print('═══════════════════════════════════════════════════════');

    // Listen to token refresh
    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM Token Refreshed: $newToken');
      // Send new token to your server
      _sendTokenToServer(newToken);
    });

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Check if app was opened from a notification
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// Request notification permissions (iOS)
  Future<void> _requestPermissions() async {
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    print('Permission status: ${settings.authorizationStatus}');
  }

  /// Configure local notifications for Android
  Future<void> _configureLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
        if (details.payload != null) {
          _handleLocalNotificationTap(details.payload!);
        }
      },
    );

    // Create Android notification channel
    const channel = AndroidNotificationChannel(
      'fahman_notifications',
      'Fahman Notifications',
      description: 'This channel is used for Fahman app notifications',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message received: ${message.messageId}');

    // Show local notification when app is in foreground
    _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'fahman_notifications',
            'Fahman Notifications',
            channelDescription:
                'This channel is used for Fahman app notifications',
            importance: Importance.high,
            priority: Priority.high,
            playSound: true,
            enableVibration: true,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            color: const Color(0xFFB4B2FF),
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

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    print('Notification tapped: ${message.messageId}');

    // Navigate to appropriate screen based on notification data
    final data = message.data;
    final notificationType = data['notificationType'] as String?;
    final relatedEntityId = data['relatedEntityId'] as String?;

    // Handle navigation based on notification type
    _navigateToScreen(notificationType, relatedEntityId);
  }

  /// Handle local notification tap
  void _handleLocalNotificationTap(String payload) {
    print('Local notification tapped: $payload');
    // Parse payload and navigate
  }

  /// Navigate to appropriate screen
  void _navigateToScreen(String? notificationType, String? entityId) {
    // Implement navigation logic based on notification type
    switch (notificationType) {
      case 'consultation':
        // Navigate to consultation screen
        break;
      case 'inquiry':
        // Navigate to inquiry screen
        break;
      case 'message':
        // Navigate to messages screen
        break;
      default:
        // Navigate to notifications screen
        break;
    }
  }

  /// Send token to server
  Future<void> _sendTokenToServer(String token) async {
    // Implement API call to send token to your server
    try {
      // await apiConsumer.post('/api/device-tokens', data: {'token': token});
      print('Token sent to server: $token');
    } catch (e) {
      print('Error sending token to server: $e');
    }
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /// Delete FCM token
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('FCM token deleted');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }
}

/// Background message handler
/// Must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');
  // Handle background message
}
