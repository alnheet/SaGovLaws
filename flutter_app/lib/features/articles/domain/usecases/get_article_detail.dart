import '../entities/article.dart';
import '../repositories/article_repository.dart';

/// Use case for getting article details
class GetArticleDetail {
  final ArticleRepository repository;

  GetArticleDetail(this.repository);

  Future<Article?> call(String articleId) {
    return repository.getArticleById(articleId);
  }
}
