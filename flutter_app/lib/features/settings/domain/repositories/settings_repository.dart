/// Settings Repository Interface
abstract class SettingsRepository {
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
