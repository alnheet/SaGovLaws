import 'package:shared_preferences/shared_preferences.dart';

/// Settings data source
abstract class SettingsLocalDataSource {
  Future<String> getTheme();
  Future<void> setTheme(String theme);
  
  Future<String> getFontSize();
  Future<void> setFontSize(String fontSize);
  
  Future<bool> getNotificationsEnabled();
  Future<void> setNotificationsEnabled(bool enabled);
  
  Future<List<int>> getNotificationHours();
  Future<void> setNotificationHours(List<int> hours);
  
  Future<List<String>> getSubscribedSources();
  Future<void> setSubscribedSources(List<String> sources);
}

/// SharedPreferences implementation
class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  static const String _themeKey = 'theme';
  static const String _fontSizeKey = 'font_size';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationHoursKey = 'notification_hours';
  static const String _subscribedSourcesKey = 'subscribed_sources';

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  @override
  Future<String> getTheme() async {
    final prefs = await _prefs;
    return prefs.getString(_themeKey) ?? 'system';
  }

  @override
  Future<void> setTheme(String theme) async {
    final prefs = await _prefs;
    await prefs.setString(_themeKey, theme);
  }

  @override
  Future<String> getFontSize() async {
    final prefs = await _prefs;
    return prefs.getString(_fontSizeKey) ?? 'medium';
  }

  @override
  Future<void> setFontSize(String fontSize) async {
    final prefs = await _prefs;
    await prefs.setString(_fontSizeKey, fontSize);
  }

  @override
  Future<bool> getNotificationsEnabled() async {
    final prefs = await _prefs;
    return prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  @override
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await _prefs;
    await prefs.setBool(_notificationsEnabledKey, enabled);
  }

  @override
  Future<List<int>> getNotificationHours() async {
    final prefs = await _prefs;
    final hours = prefs.getStringList(_notificationHoursKey);
    if (hours == null) return [8, 14, 20];
    return hours.map((h) => int.tryParse(h) ?? 8).toList();
  }

  @override
  Future<void> setNotificationHours(List<int> hours) async {
    final prefs = await _prefs;
    await prefs.setStringList(_notificationHoursKey, hours.map((h) => h.toString()).toList());
  }

  @override
  Future<List<String>> getSubscribedSources() async {
    final prefs = await _prefs;
    return prefs.getStringList(_subscribedSourcesKey) ?? ['all'];
  }

  @override
  Future<void> setSubscribedSources(List<String> sources) async {
    final prefs = await _prefs;
    await prefs.setStringList(_subscribedSourcesKey, sources);
  }
}
