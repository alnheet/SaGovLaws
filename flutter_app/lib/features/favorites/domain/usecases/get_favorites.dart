import '../entities/favorite.dart';
import '../repositories/favorites_repository.dart';

/// Get favorites use case
class GetFavorites {
  final FavoritesRepository repository;

  GetFavorites(this.repository);

  Future<List<Favorite>> call() {
    return repository.getFavorites();
  }
}
