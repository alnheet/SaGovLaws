import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Settings Repository Implementation
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl(this.localDataSource);

  @override
  Future<String> getTheme() => localDataSource.getTheme();

  @override
  Future<void> setTheme(String theme) => localDataSource.setTheme(theme);

  @override
  Future<String> getFontSize() => localDataSource.getFontSize();

  @override
  Future<void> setFontSize(String fontSize) => localDataSource.setFontSize(fontSize);

  @override
  Future<bool> getNotificationsEnabled() => localDataSource.getNotificationsEnabled();

  @override
  Future<void> setNotificationsEnabled(bool enabled) => localDataSource.setNotificationsEnabled(enabled);

  @override
  Future<List<int>> getNotificationHours() => localDataSource.getNotificationHours();

  @override
  Future<void> setNotificationHours(List<int> hours) => localDataSource.setNotificationHours(hours);

  @override
  Future<List<String>> getSubscribedSources() => localDataSource.getSubscribedSources();

  @override
  Future<void> setSubscribedSources(List<String> sources) => localDataSource.setSubscribedSources(sources);
}
