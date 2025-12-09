import '../../domain/entities/favorite.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../datasources/favorites_datasource.dart';

/// Favorites Repository Implementation
class FavoritesRepositoryImpl implements FavoritesRepository {
  final FavoritesDataSource dataSource;

  FavoritesRepositoryImpl(this.dataSource);

  @override
  Future<List<Favorite>> getFavorites() {
    return dataSource.getFavorites();
  }

  @override
  Future<bool> isFavorite(String articleId) {
    return dataSource.isFavorite(articleId);
  }

  @override
  Future<void> addFavorite(String articleId, String sourceKey) {
    return dataSource.addFavorite(articleId, sourceKey);
  }

  @override
  Future<void> removeFavorite(String articleId) {
    return dataSource.removeFavorite(articleId);
  }

  @override
  Future<bool> toggleFavorite(String articleId, String sourceKey) async {
    final isFav = await isFavorite(articleId);
    if (isFav) {
      await removeFavorite(articleId);
      return false;
    } else {
      await addFavorite(articleId, sourceKey);
      return true;
    }
  }

  @override
  Future<Set<String>> getFavoriteIds() {
    return dataSource.getFavoriteIds();
  }
}
