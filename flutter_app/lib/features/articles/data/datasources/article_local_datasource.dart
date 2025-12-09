import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/article_model.dart';

/// Local data source interface for articles
abstract class ArticleLocalDataSource {
  Future<List<ArticleModel>> getCachedArticles({
    String? sourceKey,
    int limit = 50,
  });

  Future<ArticleModel?> getCachedArticleById(String id);

  Future<void> cacheArticles(List<ArticleModel> articles);

  Future<void> clearCache();

  Future<bool> hasCache();
}

/// Local data source implementation using Hive
class ArticleLocalDataSourceImpl implements ArticleLocalDataSource {
  static const String _boxName = 'articles_cache';
  Box<String>? _box;

  Future<Box<String>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
    return _box!;
  }

  @override
  Future<List<ArticleModel>> getCachedArticles({
    String? sourceKey,
    int limit = 50,
  }) async {
    final box = await _getBox();
    final articles = <ArticleModel>[];

    for (final key in box.keys) {
      final json = box.get(key);
      if (json != null) {
        try {
          final article = ArticleModel.fromMap(jsonDecode(json));
          if (sourceKey == null || sourceKey == 'all' || article.sourceKey == sourceKey) {
            articles.add(article);
          }
        } catch (e) {
          // Skip invalid entries
        }
      }
    }

    // Sort by scraped date descending
    articles.sort((a, b) => b.scrapedAt.compareTo(a.scrapedAt));

    return articles.take(limit).toList();
  }

  @override
  Future<ArticleModel?> getCachedArticleById(String id) async {
    final box = await _getBox();
    final json = box.get(id);
    if (json == null) return null;
    
    try {
      return ArticleModel.fromMap(jsonDecode(json));
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> cacheArticles(List<ArticleModel> articles) async {
    final box = await _getBox();
    
    final entries = <String, String>{};
    for (final article in articles) {
      entries[article.id] = jsonEncode(article.toMap());
    }
    
    await box.putAll(entries);
  }

  @override
  Future<void> clearCache() async {
    final box = await _getBox();
    await box.clear();
  }

  @override
  Future<bool> hasCache() async {
    final box = await _getBox();
    return box.isNotEmpty;
  }
}
