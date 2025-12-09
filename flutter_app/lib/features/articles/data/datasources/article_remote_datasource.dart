import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article_model.dart';

/// Remote data source interface for articles
abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles({
    String? sourceKey,
    String? lastDocumentId,
    int limit = 20,
  });

  Future<ArticleModel?> getArticleById(String id);

  Future<List<ArticleModel>> searchArticles({
    required String query,
    String? sourceKey,
    int limit = 50,
  });

  Future<Map<String, int>> getArticleCountBySource();
}

/// Remote data source implementation using Firestore
class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final FirebaseFirestore firestore;

  ArticleRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<ArticleModel>> getArticles({
    String? sourceKey,
    String? lastDocumentId,
    int limit = 20,
  }) async {
    Query query = firestore
        .collection('articles')
        .orderBy('publish_date_iso', descending: true);

    if (sourceKey != null && sourceKey != 'all') {
      query = query.where('source_key', isEqualTo: sourceKey);
    }

    if (lastDocumentId != null) {
      final lastDoc =
          await firestore.collection('articles').doc(lastDocumentId).get();
      if (lastDoc.exists) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    query = query.limit(limit);

    final snapshot = await query.get();
    return snapshot.docs.map(ArticleModel.fromFirestore).toList();
  }

  @override
  Future<ArticleModel?> getArticleById(String id) async {
    final doc = await firestore.collection('articles').doc(id).get();
    if (!doc.exists) return null;
    return ArticleModel.fromFirestore(doc);
  }

  @override
  Future<List<ArticleModel>> searchArticles({
    required String query,
    String? sourceKey,
    int limit = 50,
  }) async {
    // Basic search implementation
    // For production, consider using Algolia or similar
    Query firestoreQuery = firestore
        .collection('articles')
        .orderBy('scraped_at', descending: true);

    if (sourceKey != null && sourceKey != 'all') {
      firestoreQuery = firestoreQuery.where('source_key', isEqualTo: sourceKey);
    }

    // Firestore doesn't support full-text search natively
    // We'll do client-side filtering for basic search
    final snapshot = await firestoreQuery.limit(500).get();

    final searchLower = query.toLowerCase();
    final results = snapshot.docs
        .map(ArticleModel.fromFirestore)
        .where((article) =>
            article.title.toLowerCase().contains(searchLower) ||
            (article.contentPlain?.toLowerCase().contains(searchLower) ??
                false))
        .take(limit)
        .toList();

    return results;
  }

  @override
  Future<Map<String, int>> getArticleCountBySource() async {
    // Get count per source
    final sources = [
      'cabinet_decisions',
      'royal_orders',
      'royal_decrees',
      'decisions_regulations',
      'laws_regulations',
      'ministerial_decisions',
      'authorities',
    ];

    final counts = <String, int>{};

    for (final source in sources) {
      final snapshot = await firestore
          .collection('articles')
          .where('source_key', isEqualTo: source)
          .count()
          .get();
      counts[source] = snapshot.count ?? 0;
    }

    return counts;
  }

  /// Generate mock articles for testing - REMOVED
  // Only use real data from Firestore
}
