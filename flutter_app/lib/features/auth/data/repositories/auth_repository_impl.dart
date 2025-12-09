import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Auth Repository Implementation
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<AppUser?> getCurrentUser() {
    return remoteDataSource.getCurrentUser();
  }

  @override
  Future<AppUser> login(String email, String password) {
    return remoteDataSource.login(email, password);
  }

  @override
  Future<AppUser> register(String email, String password, String? displayName) {
    return remoteDataSource.register(email, password, displayName);
  }

  @override
  Future<void> logout() {
    return remoteDataSource.logout();
  }

  @override
  Future<void> resetPassword(String email) {
    return remoteDataSource.resetPassword(email);
  }

  @override
  Future<AppUser> updateProfile({String? displayName}) {
    return remoteDataSource.updateProfile(displayName: displayName);
  }

  @override
  Future<void> updateNotificationSettings({
    bool? enabled,
    List<int>? hours,
    List<String>? subscribedSources,
  }) {
    return remoteDataSource.updateNotificationSettings(
      enabled: enabled,
      hours: hours,
      subscribedSources: subscribedSources,
    );
  }

  @override
  bool get isLoggedIn => remoteDataSource.isLoggedIn;

  @override
  Stream<AppUser?> get authStateChanges => remoteDataSource.authStateChanges;
}
