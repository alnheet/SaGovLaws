/**
 * Enhanced FCM & Local Notification Handler for Flutter
 * Handles foreground, background, and terminated state notifications
 * 
 * Place in: flutter_app/lib/core/services/notification_handler.dart
 */

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Global navigators and contexts for notification handling
class NotificationHandler {
  static final NotificationHandler _instance = NotificationHandler._internal();

  // FCM Instance
  late FirebaseMessaging firebaseMessaging;

  // Local Notifications Plugin
  late FlutterLocalNotificationsPlugin localNotifications;

  // Navigation callback
  Function(String articleId)? onNotificationTapped;

  // Subscription tracking
  final Set<String> _subscribedCategories = {};

  NotificationHandler._internal() {
    firebaseMessaging = FirebaseMessaging.instance;
    localNotifications = FlutterLocalNotificationsPlugin();
  }

  factory NotificationHandler() {
    return _instance;
  }

  /**
   * Initialize notifications system
   * Call this in main() or app initialization
   */
  Future<void> initialize() async {
    try {
      print('🔔 Initializing notification handler...');

      // Request permissions
      await _requestPermissions();

      // Setup local notifications
      await _setupLocalNotifications();

      // Setup Firebase Messaging listeners
      _setupFCMListeners();

      // Get initial message if app was closed
      final RemoteMessage? initialMessage =
          await firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        print('📬 Initial message received (app was closed)');
        _handleRemoteMessage(initialMessage);
      }

      print('✅ Notification handler initialized');
    } catch (e) {
      print('❌ Failed to initialize notifications: $e');
    }
  }

  /**
   * Request notification permissions
   */
  Future<void> _requestPermissions() async {
    try {
      final status = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('📱 Notification permission status: ${status.authorizationStatus}');

      // For iOS, also request local notification permissions
      await localNotifications
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } catch (e) {
      print('⚠️ Failed to request permissions: $e');
    }
  }

  /**
   * Setup local notifications plugin
   */
  Future<void> _setupLocalNotifications() async {
    try {
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('app_icon');

      const DarwinInitializationSettings iOSSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      final InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iOSSettings,
      );

      await localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (response) {
          print('📲 Local notification tapped: ${response.payload}');
          _handleNotificationTap(response.payload);
        },
      );

      print('✓ Local notifications setup complete');
    } catch (e) {
      print('⚠️ Failed to setup local notifications: $e');
    }
  }

  /**
   * Setup FCM listeners for different app states
   */
  void _setupFCMListeners() {
    // Foreground messages (app open)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground message received: ${message.notification?.title}');
      _handleForegroundMessage(message);
    });

    // Background message handler (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print(
          '🔔 Background notification tapped: ${message.notification?.title}');
      _handleRemoteMessage(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    // Token refresh listener
    firebaseMessaging.onTokenRefresh.listen((token) {
      print('🔑 FCM Token refreshed: ${token.substring(0, 20)}...');
      _storeFCMToken(token);
    });

    print('✓ FCM listeners setup complete');
  }

  /**
   * Handle foreground messages (show local notification)
   */
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      final notification = message.notification;
      final data = message.data;

      if (notification == null) return;

      print('📢 Showing local notification for foreground message');

      // Create notification ID from article ID
      final notificationId =
          data['article_id']?.hashCode ?? notification.hashCode;

      // Show local notification
      await localNotifications.show(
        notificationId,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'articles_channel',
            'Article Notifications',
            channelDescription: 'Notifications for new articles',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            styleInformation: BigTextStyleInformation(
              notification.body ?? '',
              htmlFormatBigText: true,
            ),
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
            presentBadge: true,
          ),
        ),
        payload: data['article_id'] ?? '',
      );

      print('✓ Local notification shown');
    } catch (e) {
      print('❌ Failed to handle foreground message: $e');
    }
  }

  /**
   * Handle notification tap
   */
  void _handleNotificationTap(String? payload) {
    if (payload == null || payload.isEmpty) {
      print('⚠️ No payload in notification');
      return;
    }

    print('👉 Notification tapped, navigating to article: $payload');

    // Navigate to article detail page
    if (onNotificationTapped != null) {
      onNotificationTapped!(payload);
    }
  }

  /**
   * Handle remote message (background/terminated)
   */
  void _handleRemoteMessage(RemoteMessage message) {
    final data = message.data;
    final articleId = data['article_id'];
    final type = data['type'];

    if (type == 'summary') {
      print('📊 Summary notification received');
      // Handle summary notification
      _navigateToHome();
    } else if (articleId != null) {
      print('📄 Article notification received: $articleId');
      _handleNotificationTap(articleId);
    }
  }

  /**
   * Background message handler (static for Firebase)
   */
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    try {
      print('🔄 Background message handler: ${message.notification?.title}');

      // Save message to local database for processing
      // This runs in an isolate, so can't access main context
      // Just log for now
      print('✓ Background message processed');
    } catch (e) {
      print('❌ Error in background message handler: $e');
    }
  }

  /**
   * Subscribe to article category notifications
   */
  Future<void> subscribeToCategory(String categoryKey) async {
    try {
      await firebaseMessaging.subscribeToTopic(categoryKey);
      _subscribedCategories.add(categoryKey);
      print('✓ Subscribed to category: $categoryKey');
    } catch (e) {
      print('❌ Failed to subscribe to category: $e');
    }
  }

  /**
   * Unsubscribe from article category notifications
   */
  Future<void> unsubscribeFromCategory(String categoryKey) async {
    try {
      await firebaseMessaging.unsubscribeFromTopic(categoryKey);
      _subscribedCategories.remove(categoryKey);
      print('✓ Unsubscribed from category: $categoryKey');
    } catch (e) {
      print('❌ Failed to unsubscribe from category: $e');
    }
  }

  /**
   * Get current FCM token
   */
  Future<String?> getToken() async {
    try {
      final token = await firebaseMessaging.getToken();
      print('🔑 FCM Token: ${token?.substring(0, 20)}...');
      return token;
    } catch (e) {
      print('❌ Failed to get FCM token: $e');
      return null;
    }
  }

  /**
   * Store FCM token in Firestore
   */
  Future<void> _storeFCMToken(String token) async {
    try {
      // This would be called from main app with proper Firestore reference
      // For now, just log
      print('💾 Storing FCM token in Firestore: ${token.substring(0, 20)}...');
    } catch (e) {
      print('⚠️ Failed to store FCM token: $e');
    }
  }

  /**
   * Navigate to home screen (for summary notifications)
   */
  void _navigateToHome() {
    // This would be implemented in main app with proper navigation
    print('🏠 Navigate to home');
  }

  /**
   * Show test notification (for testing)
   */
  Future<void> showTestNotification() async {
    try {
      await localNotifications.show(
        999,
        '📬 اختبار الإشعارات',
        'هذا اختبار لنظام الإشعارات',
        NotificationDetails(
          android: AndroidNotificationDetails(
            'test_channel',
            'Test Notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentSound: true,
          ),
        ),
      );
      print('✓ Test notification shown');
    } catch (e) {
      print('❌ Failed to show test notification: $e');
    }
  }

  /**
   * Get subscribed categories
   */
  Set<String> getSubscribedCategories() {
    return _subscribedCategories;
  }

  /**
   * Dispose/cleanup
   */
  void dispose() {
    print('🧹 Disposing notification handler');
    // Cleanup can be added here if needed
  }
}
