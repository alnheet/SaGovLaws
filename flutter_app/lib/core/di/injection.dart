import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../features/articles/data/datasources/article_local_datasource.dart';
import '../../features/articles/data/datasources/article_remote_datasource.dart';
import '../../features/articles/data/repositories/article_repository_impl.dart';
import '../../features/articles/domain/repositories/article_repository.dart';
import '../../features/articles/domain/usecases/get_articles.dart';
import '../../features/articles/domain/usecases/get_article_detail.dart';
import '../../features/articles/domain/usecases/search_articles.dart';
import '../../features/articles/presentation/bloc/articles_bloc.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login.dart';
import '../../features/auth/domain/usecases/register.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/favorites/data/datasources/favorites_datasource.dart';
import '../../features/favorites/data/repositories/favorites_repository_impl.dart';
import '../../features/favorites/domain/repositories/favorites_repository.dart';
import '../../features/favorites/domain/usecases/get_favorites.dart';
import '../../features/favorites/domain/usecases/toggle_favorite.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';

import '../../features/settings/data/datasources/settings_local_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

import '../../features/sources/data/datasources/sources_remote_datasource.dart';
import '../../features/sources/data/repositories/sources_repository_impl.dart';
import '../../features/sources/domain/repositories/sources_repository.dart';
import '../../features/sources/presentation/bloc/sources_bloc.dart';

import '../../features/notifications/data/services/notification_service.dart';

final getIt = GetIt.instance;

Future<void> configureDependencies() async {
  // Firebase instances
  getIt.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  getIt.registerLazySingleton<FirebaseMessaging>(() => FirebaseMessaging.instance);

  // Notification Service
  getIt.registerLazySingleton<NotificationService>(
    () => NotificationService(getIt<FirebaseMessaging>()),
  );

  // ===================== Data Sources =====================
  
  // Articles
  getIt.registerLazySingleton<ArticleRemoteDataSource>(
    () => ArticleRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );
  getIt.registerLazySingleton<ArticleLocalDataSource>(
    ArticleLocalDataSourceImpl.new,
  );

  // Auth
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      getIt<FirebaseAuth>(),
      getIt<FirebaseFirestore>(),
    ),
  );

  // Favorites
  getIt.registerLazySingleton<FavoritesDataSource>(
    () => FavoritesDataSourceImpl(
      getIt<FirebaseFirestore>(),
      getIt<FirebaseAuth>(),
    ),
  );

  // Settings
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    SettingsLocalDataSourceImpl.new,
  );

  // Sources
  getIt.registerLazySingleton<SourcesRemoteDataSource>(
    () => SourcesRemoteDataSourceImpl(getIt<FirebaseFirestore>()),
  );

  // ===================== Repositories =====================

  // Articles
  getIt.registerLazySingleton<ArticleRepository>(
    () => ArticleRepositoryImpl(
      getIt<ArticleRemoteDataSource>(),
      getIt<ArticleLocalDataSource>(),
    ),
  );

  // Auth
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Favorites
  getIt.registerLazySingleton<FavoritesRepository>(
    () => FavoritesRepositoryImpl(getIt<FavoritesDataSource>()),
  );

  // Settings
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<SettingsLocalDataSource>()),
  );

  // Sources
  getIt.registerLazySingleton<SourcesRepository>(
    () => SourcesRepositoryImpl(getIt<SourcesRemoteDataSource>()),
  );

  // ===================== Use Cases =====================

  // Articles
  getIt.registerLazySingleton(() => GetArticles(getIt<ArticleRepository>()));
  getIt.registerLazySingleton(() => GetArticleDetail(getIt<ArticleRepository>()));
  getIt.registerLazySingleton(() => SearchArticles(getIt<ArticleRepository>()));

  // Auth
  getIt.registerLazySingleton(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Register(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Logout(getIt<AuthRepository>()));

  // Favorites
  getIt.registerLazySingleton(() => GetFavorites(getIt<FavoritesRepository>()));
  getIt.registerLazySingleton(() => ToggleFavorite(getIt<FavoritesRepository>()));

  // ===================== BLoCs =====================

  // Articles
  getIt.registerFactory(() => ArticlesBloc(
    getArticles: getIt<GetArticles>(),
    getArticleDetail: getIt<GetArticleDetail>(),
    searchArticles: getIt<SearchArticles>(),
  ));

  // Auth
  getIt.registerFactory(() => AuthBloc(
    login: getIt<Login>(),
    register: getIt<Register>(),
    logout: getIt<Logout>(),
  ));

  // Favorites
  getIt.registerFactory(() => FavoritesBloc(
    getFavorites: getIt<GetFavorites>(),
    toggleFavorite: getIt<ToggleFavorite>(),
  ));

  // Settings
  getIt.registerFactory(() => SettingsBloc(
    repository: getIt<SettingsRepository>(),
  ));

  // Sources
  getIt.registerFactory(() => SourcesBloc(
    repository: getIt<SourcesRepository>(),
  ));
}
