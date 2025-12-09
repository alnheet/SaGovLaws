import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user.dart';

/// Auth Remote Data Source
abstract class AuthRemoteDataSource {
  Future<AppUser?> getCurrentUser();
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String email, String password, String? displayName);
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<AppUser> updateProfile({String? displayName});
  Future<void> updateNotificationSettings({
    bool? enabled,
    List<int>? hours,
    List<String>? subscribedSources,
  });
  bool get isLoggedIn;
  Stream<AppUser?> get authStateChanges;
}

/// Firebase implementation
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRemoteDataSourceImpl(this.auth, this.firestore);

  @override
  Future<AppUser?> getCurrentUser() async {
    final user = auth.currentUser;
    if (user == null) return null;
    return _getUserFromFirestore(user.uid);
  }

  @override
  Future<AppUser> login(String email, String password) async {
    final credential = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Login failed');

    return await _getUserFromFirestore(user.uid) ?? await _createUserDocument(user);
  }

  @override
  Future<AppUser> register(String email, String password, String? displayName) async {
    final credential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) throw Exception('Registration failed');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
    }

    return _createUserDocument(user, displayName: displayName);
  }

  @override
  Future<void> logout() async {
    await auth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    await auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<AppUser> updateProfile({String? displayName}) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    if (displayName != null) {
      await user.updateDisplayName(displayName);
      await firestore.collection('users').doc(user.uid).update({
        'display_name': displayName,
        'updated_at': FieldValue.serverTimestamp(),
      });
    }

    return (await _getUserFromFirestore(user.uid))!;
  }

  @override
  Future<void> updateNotificationSettings({
    bool? enabled,
    List<int>? hours,
    List<String>? subscribedSources,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final updates = <String, dynamic>{
      'updated_at': FieldValue.serverTimestamp(),
    };

    if (enabled != null) updates['notification_enabled'] = enabled;
    if (hours != null) updates['notification_hours'] = hours;
    if (subscribedSources != null) updates['subscribed_sources'] = subscribedSources;

    await firestore.collection('users').doc(user.uid).update(updates);
  }

  @override
  bool get isLoggedIn => auth.currentUser != null;

  @override
  Stream<AppUser?> get authStateChanges {
    return auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _getUserFromFirestore(user.uid);
    });
  }

  Future<AppUser?> _getUserFromFirestore(String uid) async {
    final doc = await firestore.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return AppUser(
      uid: uid,
      email: data['email'] as String?,
      displayName: data['display_name'] as String?,
      notificationEnabled: data['notification_enabled'] as bool? ?? true,
      notificationHours: (data['notification_hours'] as List<dynamic>?)?.cast<int>() ?? [8, 14, 20],
      subscribedSources: (data['subscribed_sources'] as List<dynamic>?)?.cast<String>() ?? ['all'],
      theme: data['theme'] as String? ?? 'system',
      fontSize: data['font_size'] as String? ?? 'medium',
      fcmTokens: (data['fcm_tokens'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updated_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Future<AppUser> _createUserDocument(User user, {String? displayName}) async {
    final now = DateTime.now();
    final appUser = AppUser(
      uid: user.uid,
      email: user.email,
      displayName: displayName ?? user.displayName,
      createdAt: now,
      updatedAt: now,
    );

    await firestore.collection('users').doc(user.uid).set({
      'email': appUser.email,
      'display_name': appUser.displayName,
      'notification_enabled': appUser.notificationEnabled,
      'notification_hours': appUser.notificationHours,
      'subscribed_sources': appUser.subscribedSources,
      'theme': appUser.theme,
      'font_size': appUser.fontSize,
      'fcm_tokens': appUser.fcmTokens,
      'created_at': FieldValue.serverTimestamp(),
      'updated_at': FieldValue.serverTimestamp(),
    });

    return appUser;
  }
}
