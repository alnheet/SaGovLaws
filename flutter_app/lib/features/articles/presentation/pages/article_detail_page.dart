import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../domain/entities/article.dart';
import '../bloc/articles_bloc.dart';
import '../widgets/article_export_service.dart';

/// Article detail page
class ArticleDetailPage extends StatelessWidget {
  final String articleId;

  const ArticleDetailPage({super.key, required this.articleId});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              getIt<ArticlesBloc>()..add(LoadArticleDetail(articleId)),
        ),
        BlocProvider(create: (_) => getIt<FavoritesBloc>()),
      ],
      child: const _ArticleDetailView(),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  const _ArticleDetailView();

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  final GlobalKey _exportKey = GlobalKey();
  bool _analyticsLogged = false;

  void _logArticleView(Article article) {
    if (!_analyticsLogged) {
      AnalyticsService.instance.logArticleView(
        articleId: article.id,
        sourceKey: article.sourceKey,
        title: article.title,
      );
      _analyticsLogged = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<ArticlesBloc, ArticlesState>(
      builder: (context, state) {
        if (state.status == ArticlesStatus.loading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == ArticlesStatus.failure ||
            state.selectedArticle == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'تعذر تحميل المقال',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('العودة'),
                  ),
                ],
              ),
            ),
          );
        }

        final article = state.selectedArticle!;
        final sourceColor =
            AppTheme.sourceColors[article.sourceKey] ?? AppTheme.primaryColor;

        // Log article view analytics
        _logArticleView(article);

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: sourceColor,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    article.sourceNameAr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  // Share button
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () => _shareArticle(article),
                    tooltip: 'مشاركة',
                  ),
                  // Favorite button
                  BlocBuilder<FavoritesBloc, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite =
                          favState.favoriteIds.contains(article.id);
                      return IconButton(
                        icon: Icon(
                          isFavorite ? Icons.star : Icons.star_border,
                          color: isFavorite ? Colors.amber : Colors.white,
                        ),
                        onPressed: () {
                          context.read<FavoritesBloc>().add(ToggleFavoriteEvent(
                              article.id, article.sourceKey));
                        },
                        tooltip:
                            isFavorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
                      );
                    },
                  ),
                ],
              ),

              // Content
              SliverToBoxAdapter(
                child: RepaintBoundary(
                  key: _exportKey,
                  child: Container(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            article.title,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Date info
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 20, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  article.publishDateRaw,
                                  style: theme.textTheme.bodyMedium,
                                ),
                                if (article.publishDateGregorian != null) ...[
                                  const SizedBox(width: 16),
                                  Text(
                                    '(${article.publishDateGregorian})',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Content
                          if (article.contentHtml != null)
                            Html(
                              data: article.contentHtml!,
                              style: {
                                'body': Style(
                                  fontSize: FontSize(16),
                                  lineHeight: const LineHeight(1.8),
                                  direction: TextDirection.rtl,
                                ),
                                'p': Style(
                                  margin: Margins.only(bottom: 16),
                                ),
                              },
                            )
                          else if (article.contentPlain != null)
                            SelectableText(
                              article.contentPlain!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                              ),
                            )
                          else
                            Text(
                              'المحتوى غير متوفر',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),

                          const SizedBox(height: 32),

                          // Action buttons
                          _buildActionButtons(context, article),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButtons(BuildContext context, Article article) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        // Open original
        ElevatedButton.icon(
          onPressed: () => _openUrl(article.url),
          icon: const Icon(Icons.open_in_browser),
          label: const Text('عرض في المتصفح'),
        ),

        // View PDF
        if (article.hasPdf && article.pdfUrl != null)
          ElevatedButton.icon(
            onPressed: () => _openPdfViewer(context, article),
            icon: const Icon(Icons.picture_as_pdf),
            label: const Text('عرض PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
            ),
          ),

        // Export as image
        OutlinedButton.icon(
          onPressed: () => _exportAsImage(context, article),
          icon: const Icon(Icons.image),
          label: const Text('تصدير كصورة'),
        ),
      ],
    );
  }

  void _shareArticle(Article article) {
    Share.share(
      '${article.title}\n\n${article.url}',
      subject: article.title,
    );

    // Log share analytics
    AnalyticsService.instance.logArticleShare(
      articleId: article.id,
      sourceKey: article.sourceKey,
      method: 'share_button',
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _openPdfViewer(BuildContext context, Article article) {
    context.push(
      '/home/article/${article.id}/pdf',
      extra: {
        'pdfUrl': article.pdfUrl,
        'title': article.title,
      },
    );

    // Log PDF view analytics
    AnalyticsService.instance.logPdfView(
      articleId: article.id,
      sourceKey: article.sourceKey,
    );
  }

  void _exportAsImage(BuildContext context, Article article) {
    ArticleExportService.exportAsImage(
      context: context,
      repaintBoundaryKey: _exportKey,
      article: article,
    );

    // Log export analytics
    AnalyticsService.instance.logExportAsImage(
      articleId: article.id,
      sourceKey: article.sourceKey,
    );
  }
}
