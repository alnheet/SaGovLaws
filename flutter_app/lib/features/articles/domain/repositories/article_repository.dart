import '../entities/article.dart';

/// Article Repository Interface
/// Defines the contract for article data operations
abstract class ArticleRepository {
  /// Get paginated articles
  /// [sourceKey] - Filter by source (null for all)
  /// [lastDocumentId] - For pagination
  /// [limit] - Number of articles per page
  Future<List<Article>> getArticles({
    String? sourceKey,
    String? lastDocumentId,
    int limit = 20,
  });

  /// Get a single article by ID
  Future<Article?> getArticleById(String id);

  /// Search articles by query
  Future<List<Article>> searchArticles({
    required String query,
    String? sourceKey,
    int limit = 50,
  });

  /// Get articles from local cache
  Future<List<Article>> getCachedArticles({
    String? sourceKey,
    int limit = 50,
  });

  /// Cache articles locally
  Future<void> cacheArticles(List<Article> articles);

  /// Clear local cache
  Future<void> clearCache();

  /// Get article count by source
  Future<Map<String, int>> getArticleCountBySource();
}
