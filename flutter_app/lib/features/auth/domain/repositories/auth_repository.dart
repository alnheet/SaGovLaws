import '../entities/user.dart';

/// Auth Repository Interface
abstract class AuthRepository {
  /// Get current user
  Future<AppUser?> getCurrentUser();

  /// Login with email and password
  Future<AppUser> login(String email, String password);

  /// Register new user
  Future<AppUser> register(String email, String password, String? displayName);

  /// Logout
  Future<void> logout();

  /// Reset password
  Future<void> resetPassword(String email);

  /// Update user profile
  Future<AppUser> updateProfile({String? displayName});

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? enabled,
    List<int>? hours,
    List<String>? subscribedSources,
  });

  /// Check if user is logged in
  bool get isLoggedIn;

  /// Stream of auth state changes
  Stream<AppUser?> get authStateChanges;
}
