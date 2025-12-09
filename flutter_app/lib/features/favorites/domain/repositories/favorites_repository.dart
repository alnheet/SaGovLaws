import '../entities/favorite.dart';

/// Favorites Repository Interface
abstract class FavoritesRepository {
  /// Get all favorites for current user
  Future<List<Favorite>> getFavorites();

  /// Check if article is favorited
  Future<bool> isFavorite(String articleId);

  /// Add to favorites
  Future<void> addFavorite(String articleId, String sourceKey);

  /// Remove from favorites
  Future<void> removeFavorite(String articleId);

  /// Toggle favorite status
  Future<bool> toggleFavorite(String articleId, String sourceKey);

  /// Get favorite IDs for quick lookup
  Future<Set<String>> getFavoriteIds();
}
