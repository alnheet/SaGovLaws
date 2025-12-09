import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_datasource.dart';
import '../datasources/article_local_datasource.dart';
import '../models/article_model.dart';

/// Article Repository Implementation
class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;
  final ArticleLocalDataSource localDataSource;

  ArticleRepositoryImpl(this.remoteDataSource, this.localDataSource);

  @override
  Future<List<Article>> getArticles({
    String? sourceKey,
    String? lastDocumentId,
    int limit = 20,
  }) async {
    try {
      final articles = await remoteDataSource.getArticles(
        sourceKey: sourceKey,
        lastDocumentId: lastDocumentId,
        limit: limit,
      );

      // Cache articles
      if (articles.isNotEmpty && lastDocumentId == null) {
        await localDataSource.cacheArticles(articles);
      }

      return articles;
    } catch (e) {
      // On error, try to return cached data
      if (lastDocumentId == null) {
        return getCachedArticles(sourceKey: sourceKey, limit: limit);
      }
      rethrow;
    }
  }

  @override
  Future<Article?> getArticleById(String id) async {
    try {
      final article = await remoteDataSource.getArticleById(id);
      
      // Cache the article
      if (article != null) {
        await localDataSource.cacheArticles([article]);
      }

      return article;
    } catch (e) {
      // Try local cache
      return localDataSource.getCachedArticleById(id);
    }
  }

  @override
  Future<List<Article>> searchArticles({
    required String query,
    String? sourceKey,
    int limit = 50,
  }) async {
    return remoteDataSource.searchArticles(
      query: query,
      sourceKey: sourceKey,
      limit: limit,
    );
  }

  @override
  Future<List<Article>> getCachedArticles({
    String? sourceKey,
    int limit = 50,
  }) async {
    return localDataSource.getCachedArticles(
      sourceKey: sourceKey,
      limit: limit,
    );
  }

  @override
  Future<void> cacheArticles(List<Article> articles) async {
    final models = articles.map(ArticleModel.fromEntity).toList();
    await localDataSource.cacheArticles(models);
  }

  @override
  Future<void> clearCache() async {
    await localDataSource.clearCache();
  }

  @override
  Future<Map<String, int>> getArticleCountBySource() async {
    return remoteDataSource.getArticleCountBySource();
  }
}
