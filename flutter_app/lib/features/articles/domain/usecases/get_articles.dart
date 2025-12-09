import '../entities/article.dart';
import '../repositories/article_repository.dart';

/// Use case for getting paginated articles
class GetArticles {
  final ArticleRepository repository;

  GetArticles(this.repository);

  Future<List<Article>> call({
    String? sourceKey,
    String? lastDocumentId,
    int limit = 20,
  }) {
    return repository.getArticles(
      sourceKey: sourceKey,
      lastDocumentId: lastDocumentId,
      limit: limit,
    );
  }
}
