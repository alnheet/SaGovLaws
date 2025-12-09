import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Notification Service
/// Handles FCM and local notifications
class NotificationService {
  final FirebaseMessaging messaging;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  NotificationService(this.messaging);

  /// Initialize notification service
  Future<void> initialize() async {
    // Request permission
    await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
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
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels (Android)
    await _createNotificationChannels();

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle notification taps when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
  }

  /// Get FCM token
  Future<String?> getToken() async {
    return messaging.getToken();
  }

  /// Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    await messaging.subscribeToTopic(topic);
  }

  /// Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    await messaging.unsubscribeFromTopic(topic);
  }

  /// Subscribe to all default topics
  Future<void> subscribeToDefaultTopics() async {
    await subscribeToTopic('news_updates');
  }

  /// Update source subscriptions
  Future<void> updateSourceSubscriptions(List<String> sources) async {
    final allSources = [
      'cabinet_decisions',
      'royal_orders',
      'royal_decrees',
      'decisions_regulations',
      'laws_regulations',
      'ministerial_decisions',
      'authorities',
    ];

    // Unsubscribe from all
    for (final source in allSources) {
      await unsubscribeFromTopic('news_$source');
    }
    await unsubscribeFromTopic('news_updates');

    // Subscribe to selected
    if (sources.contains('all')) {
      await subscribeToTopic('news_updates');
    } else {
      for (final source in sources) {
        await subscribeToTopic('news_$source');
      }
    }
  }

  /// Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const channels = [
      AndroidNotificationChannel(
        'new_articles',
        'قرارات جديدة',
        description: 'إشعارات عند نشر قرارات جديدة',
        importance: Importance.high,
      ),
      AndroidNotificationChannel(
        'daily_summary',
        'الملخص اليومي',
        description: 'ملخص يومي للقرارات الجديدة',
        importance: Importance.defaultImportance,
      ),
    ];

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      for (final channel in channels) {
        await androidPlugin.createNotificationChannel(channel);
      }
    }
  }

  /// Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final data = message.data;
    final notification = message.notification;

    if (notification != null) {
      // Show local notification
      _showLocalNotification(
        title: notification.title ?? 'راصد أم القرى',
        body: notification.body ?? '',
        payload: data['article_id'],
      );
    } else if (data['type'] == 'new_article') {
      // Data-only message, show local notification
      _showLocalNotification(
        title: 'قرار جديد - ${data['source_name_ar']}',
        body: data['title'] ?? '',
        payload: data['article_id'],
      );
    }
  }

  /// Handle background messages
  static Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    // Handle background data message
    // This runs in a separate isolate
  }

  /// Handle when user taps notification to open app
  void _handleMessageOpenedApp(RemoteMessage message) {
    final articleId = message.data['article_id'];
    if (articleId != null) {
      // Navigate to article - this would need to be implemented with a navigation callback
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    final articleId = response.payload;
    if (articleId != null) {
      // Navigate to article
    }
  }

  /// Show local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'new_articles',
      'قرارات جديدة',
      channelDescription: 'إشعارات عند نشر قرارات جديدة',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule local notifications at specific hours
  Future<void> scheduleNotifications(List<int> hours) async {
    // Cancel existing scheduled notifications
    await _localNotifications.cancelAll();

    // Schedule for each hour
    // Note: In production, you'd use zonedSchedule with proper timezone handling
  }
}
