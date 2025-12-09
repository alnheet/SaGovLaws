import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Analytics
/// Tracks user behavior and app events for insights
class AnalyticsService {
  static AnalyticsService? _instance;
  static AnalyticsService get instance => _instance ??= AnalyticsService._();

  AnalyticsService._();

  late final FirebaseAnalytics _analytics;
  late final FirebaseAnalyticsObserver _observer;
  bool _initialized = false;

  /// Initialize Analytics
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);

      // Set analytics collection enabled based on debug mode
      await _analytics
          .setAnalyticsCollectionEnabled(!kDebugMode || kProfileMode);

      _initialized = true;
      debugPrint('Analytics: Initialized successfully');
    } catch (e) {
      debugPrint('Analytics: Error initializing - $e');
    }
  }

  /// Get the analytics observer for navigation tracking
  FirebaseAnalyticsObserver get observer {
    if (!_initialized) {
      _analytics = FirebaseAnalytics.instance;
      _observer = FirebaseAnalyticsObserver(analytics: _analytics);
    }
    return _observer;
  }

  /// Set user ID for tracking
  Future<void> setUserId(String? userId) async {
    if (!_initialized) return;
    await _analytics.setUserId(id: userId);
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!_initialized) return;
    await _analytics.setUserProperty(name: name, value: value);
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_initialized) return;
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClass,
    );
  }

  /// Log article view
  Future<void> logArticleView({
    required String articleId,
    required String sourceKey,
    required String title,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'article_view',
      parameters: {
        'article_id': articleId,
        'source_key': sourceKey,
        'title': title.substring(0, title.length > 100 ? 100 : title.length),
      },
    );
  }

  /// Log article share
  Future<void> logArticleShare({
    required String articleId,
    required String sourceKey,
    required String method,
  }) async {
    if (!_initialized) return;
    await _analytics.logShare(
      contentType: 'article',
      itemId: articleId,
      method: method,
    );
  }

  /// Log PDF view
  Future<void> logPdfView({
    required String articleId,
    required String sourceKey,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'pdf_view',
      parameters: {
        'article_id': articleId,
        'source_key': sourceKey,
      },
    );
  }

  /// Log export as image
  Future<void> logExportAsImage({
    required String articleId,
    required String sourceKey,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'export_as_image',
      parameters: {
        'article_id': articleId,
        'source_key': sourceKey,
      },
    );
  }

  /// Log favorite toggle
  Future<void> logFavoriteToggle({
    required String articleId,
    required String sourceKey,
    required bool isFavorite,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: isFavorite ? 'add_favorite' : 'remove_favorite',
      parameters: {
        'article_id': articleId,
        'source_key': sourceKey,
      },
    );
  }

  /// Log search
  Future<void> logSearch({
    required String searchTerm,
    String? sourceFilter,
  }) async {
    if (!_initialized) return;
    await _analytics.logSearch(
      searchTerm: searchTerm,
      parameters: {
        if (sourceFilter != null) 'source_filter': sourceFilter,
      },
    );
  }

  /// Log source filter change
  Future<void> logSourceFilterChange({
    required String sourceKey,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'source_filter_change',
      parameters: {
        'source_key': sourceKey,
      },
    );
  }

  /// Log login
  Future<void> logLogin({required String method}) async {
    if (!_initialized) return;
    await _analytics.logLogin(loginMethod: method);
  }

  /// Log signup
  Future<void> logSignUp({required String method}) async {
    if (!_initialized) return;
    await _analytics.logSignUp(signUpMethod: method);
  }

  /// Log theme change
  Future<void> logThemeChange({required String theme}) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'theme_change',
      parameters: {
        'theme': theme,
      },
    );
  }

  /// Log notification toggle
  Future<void> logNotificationToggle({required bool enabled}) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: 'notification_toggle',
      parameters: {
        'enabled': enabled.toString(),
      },
    );
  }

  /// Log app open
  Future<void> logAppOpen() async {
    if (!_initialized) return;
    await _analytics.logAppOpen();
  }

  /// Log custom event
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    if (!_initialized) return;
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
