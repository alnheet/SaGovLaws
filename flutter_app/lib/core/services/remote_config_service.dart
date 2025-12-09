import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service for Firebase Remote Config
/// Manages dynamic app configurations without requiring app updates
class RemoteConfigService {
  static RemoteConfigService? _instance;
  static RemoteConfigService get instance =>
      _instance ??= RemoteConfigService._();

  RemoteConfigService._();

  late final FirebaseRemoteConfig _remoteConfig;
  bool _initialized = false;

  // Config Keys
  static const String keyAppMinVersion = 'app_min_version';
  static const String keyMaintenanceMode = 'maintenance_mode';
  static const String keyMaintenanceMessage = 'maintenance_message';
  static const String keyScrapingEnabled = 'scraping_enabled';
  static const String keyDefaultSource = 'default_source';
  static const String keyArticleRefreshInterval =
      'article_refresh_interval_minutes';
  static const String keyMaxCacheAge = 'max_cache_age_hours';
  static const String keyFeaturedSourcesOrder = 'featured_sources_order';
  static const String keyShowAds = 'show_ads';
  static const String keyAdBannerUnitId = 'ad_banner_unit_id';

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    if (_initialized) return;

    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig.setDefaults({
        keyAppMinVersion: '1.0.0',
        keyMaintenanceMode: false,
        keyMaintenanceMessage: 'التطبيق قيد الصيانة، يرجى المحاولة لاحقاً',
        keyScrapingEnabled: true,
        keyDefaultSource: 'all',
        keyArticleRefreshInterval: 30,
        keyMaxCacheAge: 24,
        keyFeaturedSourcesOrder: 'uqu,moi,moe,ksu,kau',
        keyShowAds: false,
        keyAdBannerUnitId: '',
      });

      // Configure fetch settings
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval:
            kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
      ));

      // Fetch and activate
      await _remoteConfig.fetchAndActivate();

      // Listen to config changes (real-time)
      _remoteConfig.onConfigUpdated.listen((event) async {
        await _remoteConfig.activate();
        debugPrint('RemoteConfig: Config updated and activated');
      });

      _initialized = true;
      debugPrint('RemoteConfig: Initialized successfully');
    } catch (e) {
      debugPrint('RemoteConfig: Error initializing - $e');
      // Continue with defaults if remote config fails
      _initialized = true;
    }
  }

  /// Get minimum app version required
  String get appMinVersion => _getString(keyAppMinVersion);

  /// Check if app is in maintenance mode
  bool get isMaintenanceMode => _getBool(keyMaintenanceMode);

  /// Get maintenance message
  String get maintenanceMessage => _getString(keyMaintenanceMessage);

  /// Check if scraping is enabled
  bool get isScrapingEnabled => _getBool(keyScrapingEnabled);

  /// Get default source to show
  String get defaultSource => _getString(keyDefaultSource);

  /// Get article refresh interval in minutes
  int get articleRefreshIntervalMinutes => _getInt(keyArticleRefreshInterval);

  /// Get max cache age in hours
  int get maxCacheAgeHours => _getInt(keyMaxCacheAge);

  /// Get featured sources order
  List<String> get featuredSourcesOrder {
    final value = _getString(keyFeaturedSourcesOrder);
    return value
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  /// Check if ads should be shown
  bool get showAds => _getBool(keyShowAds);

  /// Get ad banner unit ID
  String get adBannerUnitId => _getString(keyAdBannerUnitId);

  // Helper methods
  String _getString(String key) {
    if (!_initialized) return '';
    return _remoteConfig.getString(key);
  }

  bool _getBool(String key) {
    if (!_initialized) return false;
    return _remoteConfig.getBool(key);
  }

  int _getInt(String key) {
    if (!_initialized) return 0;
    return _remoteConfig.getInt(key);
  }

  /// Force refresh config (ignores minimum fetch interval)
  Future<bool> forceRefresh() async {
    if (!_initialized) return false;

    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: Duration.zero,
      ));

      final updated = await _remoteConfig.fetchAndActivate();

      // Reset minimum fetch interval
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval:
            kDebugMode ? const Duration(minutes: 5) : const Duration(hours: 12),
      ));

      return updated;
    } catch (e) {
      debugPrint('RemoteConfig: Force refresh failed - $e');
      return false;
    }
  }
}
