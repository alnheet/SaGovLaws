import '../repositories/favorites_repository.dart';

/// Toggle favorite use case
class ToggleFavorite {
  final FavoritesRepository repository;

  ToggleFavorite(this.repository);

  Future<bool> call(String articleId, String sourceKey) {
    return repository.toggleFavorite(articleId, sourceKey);
  }
}
