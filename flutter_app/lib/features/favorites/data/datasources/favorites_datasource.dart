import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/favorite.dart';

/// Favorites data source
abstract class FavoritesDataSource {
  Future<List<Favorite>> getFavorites();
  Future<bool> isFavorite(String articleId);
  Future<void> addFavorite(String articleId, String sourceKey);
  Future<void> removeFavorite(String articleId);
  Future<Set<String>> getFavoriteIds();
}

/// Firestore implementation
class FavoritesDataSourceImpl implements FavoritesDataSource {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;

  FavoritesDataSourceImpl(this.firestore, this.auth);

  String? get _userId => auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _favoritesCollection {
    final userId = _userId;
    if (userId == null) return null;
    return firestore.collection('users').doc(userId).collection('favorites');
  }

  @override
  Future<List<Favorite>> getFavorites() async {
    final collection = _favoritesCollection;
    if (collection == null) return [];

    final snapshot = await collection.orderBy('added_at', descending: true).get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Favorite(
        articleId: doc.id,
        sourceKey: data['source_key'] as String? ?? '',
        addedAt: (data['added_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    }).toList();
  }

  @override
  Future<bool> isFavorite(String articleId) async {
    final collection = _favoritesCollection;
    if (collection == null) return false;

    final doc = await collection.doc(articleId).get();
    return doc.exists;
  }

  @override
  Future<void> addFavorite(String articleId, String sourceKey) async {
    final collection = _favoritesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(articleId).set({
      'source_key': sourceKey,
      'added_at': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> removeFavorite(String articleId) async {
    final collection = _favoritesCollection;
    if (collection == null) throw Exception('User not authenticated');

    await collection.doc(articleId).delete();
  }

  @override
  Future<Set<String>> getFavoriteIds() async {
    final collection = _favoritesCollection;
    if (collection == null) return {};

    final snapshot = await collection.get();
    return snapshot.docs.map((doc) => doc.id).toSet();
  }
}
