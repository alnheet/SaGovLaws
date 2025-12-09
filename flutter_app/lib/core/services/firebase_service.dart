// Firebase Service for Flutter Web
// This service manages all Firebase operations for the Flutter application

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  // Singleton instance
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Getters for Firebase instances
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;

  // ===== Authentication Methods =====

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await userCredential.user?.updateDisplayName(displayName);

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!);

      return userCredential;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Stream of authentication state
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ===== Firestore Methods =====

  /// Get user document
  Future<DocumentSnapshot> getUserDocument(String userId) {
    return _firestore.collection('users').doc(userId).get();
  }

  /// Update user document
  Future<void> updateUserDocument(String userId, Map<String, dynamic> data) {
    return _firestore.collection('users').doc(userId).update(data);
  }

  /// Get all articles
  Future<QuerySnapshot> getArticles() {
    return _firestore
        .collection('articles')
        .orderBy('createdAt', descending: true)
        .get();
  }

  /// Get article by ID
  Future<DocumentSnapshot> getArticle(String articleId) {
    return _firestore.collection('articles').doc(articleId).get();
  }

  /// Search articles
  Future<QuerySnapshot> searchArticles(String query) {
    return _firestore
        .collection('articles')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();
  }

  /// Add favorite article
  Future<void> addFavorite(String userId, String articleId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(articleId)
        .set({
      'articleId': articleId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Remove favorite article
  Future<void> removeFavorite(String userId, String articleId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc(articleId)
        .delete();
  }

  /// Get user favorites
  Future<QuerySnapshot> getUserFavorites(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();
  }

  // ===== Storage Methods =====

  /// Upload file to storage
  Future<String> uploadFile(String path, String fileName) async {
    try {
      // Implementation for file upload
      // Note: Storage operations require firebase_storage package
      return 'Upload URL placeholder';
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }

  /// Download file from storage
  Future<void> downloadFile(String url, String savePath) async {
    try {
      // Implementation for file download
      // Note: Storage operations require firebase_storage package and dart:io
    } catch (e) {
      throw Exception('Failed to download file: $e');
    }
  }

  // ===== Private Methods =====

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user) {
    return _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }
}
