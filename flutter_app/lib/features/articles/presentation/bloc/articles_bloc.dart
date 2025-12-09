import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/article.dart';
import '../../domain/usecases/get_articles.dart';
import '../../domain/usecases/get_article_detail.dart';
import '../../domain/usecases/search_articles.dart';

// Events
abstract class ArticlesEvent extends Equatable {
  const ArticlesEvent();

  @override
  List<Object?> get props => [];
}

class LoadArticles extends ArticlesEvent {
  final String? sourceKey;
  final bool refresh;

  const LoadArticles({this.sourceKey, this.refresh = false});

  @override
  List<Object?> get props => [sourceKey, refresh];
}

class LoadMoreArticles extends ArticlesEvent {
  final String? sourceKey;

  const LoadMoreArticles({this.sourceKey});

  @override
  List<Object?> get props => [sourceKey];
}

class LoadArticleDetail extends ArticlesEvent {
  final String articleId;

  const LoadArticleDetail(this.articleId);

  @override
  List<Object?> get props => [articleId];
}

class SearchArticlesEvent extends ArticlesEvent {
  final String query;
  final String? sourceKey;

  const SearchArticlesEvent({required this.query, this.sourceKey});

  @override
  List<Object?> get props => [query, sourceKey];
}

// State
class ArticlesState extends Equatable {
  final ArticlesStatus status;
  final List<Article> articles;
  final Article? selectedArticle;
  final String? error;
  final bool hasReachedMax;
  final String? currentSourceKey;
  final String? lastDocumentId;

  const ArticlesState({
    this.status = ArticlesStatus.initial,
    this.articles = const [],
    this.selectedArticle,
    this.error,
    this.hasReachedMax = false,
    this.currentSourceKey,
    this.lastDocumentId,
  });

  ArticlesState copyWith({
    ArticlesStatus? status,
    List<Article>? articles,
    Article? selectedArticle,
    String? error,
    bool? hasReachedMax,
    String? currentSourceKey,
    String? lastDocumentId,
  }) {
    return ArticlesState(
      status: status ?? this.status,
      articles: articles ?? this.articles,
      selectedArticle: selectedArticle ?? this.selectedArticle,
      error: error ?? this.error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      currentSourceKey: currentSourceKey ?? this.currentSourceKey,
      lastDocumentId: lastDocumentId ?? this.lastDocumentId,
    );
  }

  @override
  List<Object?> get props => [
        status,
        articles,
        selectedArticle,
        error,
        hasReachedMax,
        currentSourceKey,
        lastDocumentId,
      ];
}

enum ArticlesStatus {
  initial,
  loading,
  success,
  failure,
  loadingMore,
  searching,
}

// BLoC
class ArticlesBloc extends Bloc<ArticlesEvent, ArticlesState> {
  final GetArticles getArticles;
  final GetArticleDetail getArticleDetail;
  final SearchArticles searchArticles;

  ArticlesBloc({
    required this.getArticles,
    required this.getArticleDetail,
    required this.searchArticles,
  }) : super(const ArticlesState()) {
    on<LoadArticles>(_onLoadArticles);
    on<LoadMoreArticles>(_onLoadMoreArticles);
    on<LoadArticleDetail>(_onLoadArticleDetail);
    on<SearchArticlesEvent>(_onSearchArticles);
  }

  Future<void> _onLoadArticles(
    LoadArticles event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(state.copyWith(
      status: ArticlesStatus.loading,
      currentSourceKey: event.sourceKey,
    ));

    try {
      final articles = await getArticles(
        sourceKey: event.sourceKey,
        limit: 20,
      );

      emit(state.copyWith(
        status: ArticlesStatus.success,
        articles: articles,
        hasReachedMax: articles.length < 20,
        lastDocumentId: articles.isNotEmpty ? articles.last.id : null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadMoreArticles(
    LoadMoreArticles event,
    Emitter<ArticlesState> emit,
  ) async {
    if (state.hasReachedMax) return;

    emit(state.copyWith(status: ArticlesStatus.loadingMore));

    try {
      final articles = await getArticles(
        sourceKey: event.sourceKey ?? state.currentSourceKey,
        lastDocumentId: state.lastDocumentId,
        limit: 20,
      );

      emit(state.copyWith(
        status: ArticlesStatus.success,
        articles: [...state.articles, ...articles],
        hasReachedMax: articles.length < 20,
        lastDocumentId: articles.isNotEmpty ? articles.last.id : state.lastDocumentId,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onLoadArticleDetail(
    LoadArticleDetail event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(state.copyWith(status: ArticlesStatus.loading));

    try {
      final article = await getArticleDetail(event.articleId);

      emit(state.copyWith(
        status: ArticlesStatus.success,
        selectedArticle: article,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onSearchArticles(
    SearchArticlesEvent event,
    Emitter<ArticlesState> emit,
  ) async {
    emit(state.copyWith(status: ArticlesStatus.searching));

    try {
      final articles = await searchArticles(
        query: event.query,
        sourceKey: event.sourceKey,
      );

      emit(state.copyWith(
        status: ArticlesStatus.success,
        articles: articles,
        hasReachedMax: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ArticlesStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
