import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/favorite.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

// Events
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoritesEvent {}

class ToggleFavoriteEvent extends FavoritesEvent {
  final String articleId;
  final String sourceKey;

  const ToggleFavoriteEvent(this.articleId, this.sourceKey);

  @override
  List<Object?> get props => [articleId, sourceKey];
}

// State
class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final List<Favorite> favorites;
  final Set<String> favoriteIds;
  final String? error;

  const FavoritesState({
    this.status = FavoritesStatus.initial,
    this.favorites = const [],
    this.favoriteIds = const {},
    this.error,
  });

  FavoritesState copyWith({
    FavoritesStatus? status,
    List<Favorite>? favorites,
    Set<String>? favoriteIds,
    String? error,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favorites: favorites ?? this.favorites,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, favorites, favoriteIds, error];
}

enum FavoritesStatus {
  initial,
  loading,
  success,
  failure,
}

// BLoC
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  FavoritesBloc({
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(const FavoritesState()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoritesState> emit,
  ) async {
    emit(state.copyWith(status: FavoritesStatus.loading));

    try {
      final favorites = await getFavorites();
      final ids = favorites.map((f) => f.articleId).toSet();

      emit(state.copyWith(
        status: FavoritesStatus.success,
        favorites: favorites,
        favoriteIds: ids,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FavoritesStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<FavoritesState> emit,
  ) async {
    try {
      final isNowFavorite = await toggleFavorite(event.articleId, event.sourceKey);

      final newIds = Set<String>.from(state.favoriteIds);
      if (isNowFavorite) {
        newIds.add(event.articleId);
      } else {
        newIds.remove(event.articleId);
      }

      emit(state.copyWith(favoriteIds: newIds));

      // Reload full list
      final favorites = await getFavorites();
      emit(state.copyWith(favorites: favorites));
    } catch (e) {
      // Ignore toggle errors for now
    }
  }
}
