import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../articles/presentation/bloc/articles_bloc.dart';
import '../../../articles/presentation/widgets/article_card.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../sources/data/models/source_model.dart';

/// Search Page
class SearchPage extends StatefulWidget {
  final String? initialQuery;

  const SearchPage({super.key, this.initialQuery});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _searchController = TextEditingController();
  String? _selectedSourceKey;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _searchController.text = widget.initialQuery!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<ArticlesBloc>()),
        BlocProvider(create: (_) => getIt<FavoritesBloc>()..add(LoadFavorites())),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('البحث'),
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Search field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن قرار أو نظام...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                    ),
                    textInputAction: TextInputAction.search,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (query) => _performSearch(context, query),
                  ),

                  const SizedBox(height: 12),

                  // Source filter
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildFilterChip(
                          context,
                          'الكل',
                          null,
                          _selectedSourceKey == null,
                        ),
                        ...DefaultSources.sources.map((source) => _buildFilterChip(
                              context,
                              source.nameAr,
                              source.id,
                              _selectedSourceKey == source.id,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Results
            Expanded(
              child: BlocBuilder<ArticlesBloc, ArticlesState>(
                builder: (context, state) {
                  if (state.status == ArticlesStatus.initial) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'ابحث عن القرارات والأنظمة',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state.status == ArticlesStatus.searching) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.articles.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'لا توجد نتائج',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'جرب كلمات بحث مختلفة',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: state.articles.length,
                    itemBuilder: (context, index) {
                      final article = state.articles[index];
                      return BlocBuilder<FavoritesBloc, FavoritesState>(
                        builder: (context, favState) {
                          final isFavorite = favState.favoriteIds.contains(article.id);
                          return ArticleCard(
                            article: article,
                            isFavorite: isFavorite,
                            onFavoriteToggle: () {
                              context.read<FavoritesBloc>().add(
                                    ToggleFavoriteEvent(article.id, article.sourceKey),
                                  );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    String? sourceKey,
    bool isSelected,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSourceKey = selected ? sourceKey : null;
          });
          if (_searchController.text.isNotEmpty) {
            _performSearch(context, _searchController.text);
          }
        },
      ),
    );
  }

  void _performSearch(BuildContext context, String query) {
    if (query.trim().isEmpty) return;

    context.read<ArticlesBloc>().add(
          SearchArticlesEvent(
            query: query.trim(),
            sourceKey: _selectedSourceKey,
          ),
        );
  }
}
