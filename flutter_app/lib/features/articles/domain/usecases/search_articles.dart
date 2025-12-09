import '../entities/article.dart';
import '../repositories/article_repository.dart';

/// Use case for searching articles
class SearchArticles {
  final ArticleRepository repository;

  SearchArticles(this.repository);

  Future<List<Article>> call({
    required String query,
    String? sourceKey,
    int limit = 50,
  }) {
    return repository.searchArticles(
      query: query,
      sourceKey: sourceKey,
      limit: limit,
    );
  }
}
