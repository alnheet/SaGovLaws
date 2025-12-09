import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/google_ai_colors.dart';
import '../../../articles/presentation/bloc/articles_bloc.dart';
import '../../../articles/presentation/widgets/article_card_new.dart';
import '../../../favorites/presentation/bloc/favorites_bloc.dart';
import '../../../sources/data/models/source_model.dart';
import '../../../sources/domain/entities/source.dart' as entities;
import '../../../sources/presentation/bloc/sources_bloc.dart';

/// Home Page - Google AI Studio Style
/// Responsive layout with collapsible sidebar and central workspace
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<entities.Source> _sources = DefaultSources.sources;
  String? _selectedSourceKey;
  bool _isSidebarExpanded = true;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1200;
    // final isTablet = screenWidth >= 768 && screenWidth < 1200;
    final isMobile = screenWidth < 768;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
            create: (_) => getIt<ArticlesBloc>()..add(const LoadArticles())),
        BlocProvider(
            create: (_) => getIt<FavoritesBloc>()..add(LoadFavorites())),
        BlocProvider(create: (_) => getIt<SourcesBloc>()..add(LoadSources())),
      ],
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Row(
          children: [
            // Sidebar (Desktop/Tablet only)
            if (!isMobile) _buildSidebar(context, isDesktop),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // Top App Bar
                  _buildAppBar(context, isMobile),

                  // Content Area
                  Expanded(
                    child: _buildContentArea(context),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Bottom Nav for Mobile
        bottomNavigationBar: isMobile ? _buildBottomNav(context) : null,
        // Drawer for Mobile
        drawer: isMobile ? _buildMobileDrawer(context) : null,
      ),
    );
  }

  /// Sidebar - Collapsible navigation rail
  Widget _buildSidebar(BuildContext context, bool isDesktop) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: _isSidebarExpanded ? 280 : 72,
      decoration: BoxDecoration(
        color:
            isDark ? GoogleAIColors.surfaceDark : GoogleAIColors.surfaceLight,
        border: Border(
          left: BorderSide(
            color:
                isDark ? GoogleAIColors.borderDark : GoogleAIColors.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Header
          _buildSidebarHeader(context, isDark),

          const SizedBox(height: GoogleAIColors.spacing4),

          // Navigation Items
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: _isSidebarExpanded
                    ? GoogleAIColors.spacing3
                    : GoogleAIColors.spacing2,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // All Articles
                  _buildNavItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    label: 'جميع الأخبار',
                    isSelected: _selectedSourceKey == null,
                    onTap: () => _selectSource(context, null),
                    isDark: isDark,
                  ),

                  const SizedBox(height: GoogleAIColors.spacing2),

                  // Divider with label
                  if (_isSidebarExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GoogleAIColors.spacing3,
                        vertical: GoogleAIColors.spacing2,
                      ),
                      child: Text(
                        'الأقسام',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? GoogleAIColors.textTertiaryDark
                              : GoogleAIColors.textTertiaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                  // Source Items
                  ..._sources.map((source) => _buildNavItem(
                        context,
                        icon: _getIconData(source.icon),
                        label: source.nameAr,
                        isSelected: _selectedSourceKey == source.id,
                        color: Color(source.colorValue),
                        onTap: () => _selectSource(context, source.id),
                        isDark: isDark,
                      )),
                ],
              ),
            ),
          ),

          // Footer Actions
          _buildSidebarFooter(context, isDark),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(
        _isSidebarExpanded ? GoogleAIColors.spacing4 : GoogleAIColors.spacing3,
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [GoogleAIColors.deepBlue, GoogleAIColors.warmPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
            ),
            child: const Icon(
              Icons.newspaper_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),

          if (_isSidebarExpanded) ...[
            const SizedBox(width: GoogleAIColors.spacing3),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'راصد',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'جريدة أم القرى',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isDark
                          ? GoogleAIColors.textSecondaryDark
                          : GoogleAIColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Collapse button
          IconButton(
            icon: Icon(
              _isSidebarExpanded
                  ? Icons.keyboard_arrow_right_rounded
                  : Icons.keyboard_arrow_left_rounded,
              color: isDark
                  ? GoogleAIColors.textSecondaryDark
                  : GoogleAIColors.textSecondaryLight,
            ),
            onPressed: () {
              setState(() {
                _isSidebarExpanded = !_isSidebarExpanded;
              });
            },
            tooltip: _isSidebarExpanded ? 'تصغير' : 'توسيع',
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final itemColor = color ?? GoogleAIColors.deepBlue;
    final bgColor = isSelected
        ? (isDark
            ? itemColor.withValues(alpha: 0.15)
            : itemColor.withValues(alpha: 0.1))
        : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.only(bottom: GoogleAIColors.spacing1),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: GoogleAIColors.spacing3,
              vertical: _isSidebarExpanded
                  ? GoogleAIColors.spacing3
                  : GoogleAIColors.spacing2,
            ),
            child: Row(
              mainAxisAlignment: _isSidebarExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? itemColor
                      : (isDark
                          ? GoogleAIColors.textSecondaryDark
                          : GoogleAIColors.textSecondaryLight),
                ),
                if (_isSidebarExpanded) ...[
                  const SizedBox(width: GoogleAIColors.spacing3),
                  Expanded(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected
                            ? itemColor
                            : (isDark
                                ? GoogleAIColors.textPrimaryDark
                                : GoogleAIColors.textPrimaryLight),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(GoogleAIColors.spacing3),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                isDark ? GoogleAIColors.borderDark : GoogleAIColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: _isSidebarExpanded
            ? MainAxisAlignment.start
            : MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark
                  ? GoogleAIColors.textSecondaryDark
                  : GoogleAIColors.textSecondaryLight,
            ),
            onPressed: () => context.push('/settings'),
            tooltip: 'الإعدادات',
          ),
          if (_isSidebarExpanded) ...[
            IconButton(
              icon: Icon(
                Icons.star_outline_rounded,
                color: isDark
                    ? GoogleAIColors.textSecondaryDark
                    : GoogleAIColors.textSecondaryLight,
              ),
              onPressed: () => context.push('/favorites'),
              tooltip: 'المفضلة',
            ),
          ],
        ],
      ),
    );
  }

  /// Top App Bar
  Widget _buildAppBar(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: GoogleAIColors.spacing4),
      decoration: BoxDecoration(
        color:
            isDark ? GoogleAIColors.surfaceDark : GoogleAIColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color:
                isDark ? GoogleAIColors.borderDark : GoogleAIColors.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          // Menu button (mobile)
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),

          // Title / Current section
          Expanded(
            child: Text(
              _selectedSourceKey == null
                  ? 'جميع الأخبار'
                  : _sources
                      .firstWhere(
                        (s) => s.id == _selectedSourceKey,
                        orElse: () => _sources.first,
                      )
                      .nameAr,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Search
          Container(
            width: 300,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? GoogleAIColors.surfaceContainerDark
                  : GoogleAIColors.surfaceContainerLight,
              borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
              border: Border.all(
                color: isDark
                    ? GoogleAIColors.borderDark
                    : GoogleAIColors.borderLight,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
              child: InkWell(
                onTap: () => context.push('/search'),
                borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GoogleAIColors.spacing4,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.search_rounded,
                        size: 20,
                        color: isDark
                            ? GoogleAIColors.textTertiaryDark
                            : GoogleAIColors.textTertiaryLight,
                      ),
                      const SizedBox(width: GoogleAIColors.spacing2),
                      Text(
                        'بحث في الأخبار...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? GoogleAIColors.textTertiaryDark
                              : GoogleAIColors.textTertiaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: GoogleAIColors.spacing4),

          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              context.read<ArticlesBloc>().add(
                    LoadArticles(sourceKey: _selectedSourceKey, refresh: true),
                  );
            },
            tooltip: 'تحديث',
          ),
        ],
      ),
    );
  }

  /// Main Content Area
  Widget _buildContentArea(BuildContext context) {
    return BlocBuilder<ArticlesBloc, ArticlesState>(
      builder: (context, state) {
        if (state.status == ArticlesStatus.loading && state.articles.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state.status == ArticlesStatus.failure && state.articles.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.error_outline_rounded,
            title: 'حدث خطأ',
            subtitle: state.error ?? 'تعذر تحميل الأخبار',
            actionLabel: 'إعادة المحاولة',
            onAction: () {
              context.read<ArticlesBloc>().add(
                    LoadArticles(sourceKey: _selectedSourceKey, refresh: true),
                  );
            },
          );
        }

        if (state.articles.isEmpty) {
          return _buildEmptyState(
            context,
            icon: Icons.inbox_rounded,
            title: 'لا توجد أخبار',
            subtitle: 'لم يتم العثور على أخبار في هذا القسم',
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ArticlesBloc>().add(
                  LoadArticles(sourceKey: _selectedSourceKey, refresh: true),
                );
          },
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: GoogleAIColors.spacing4,
            ),
            itemCount: state.articles.length + (!state.hasReachedMax ? 1 : 0),
            itemBuilder: (context, index) {
              if (index >= state.articles.length) {
                // Load more indicator
                if (state.status != ArticlesStatus.loading) {
                  context.read<ArticlesBloc>().add(
                        LoadMoreArticles(sourceKey: _selectedSourceKey),
                      );
                }
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(GoogleAIColors.spacing4),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

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
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GoogleAIColors.spacing8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: isDark
                    ? GoogleAIColors.surfaceContainerDark
                    : GoogleAIColors.surfaceContainerLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: isDark
                    ? GoogleAIColors.textTertiaryDark
                    : GoogleAIColors.textTertiaryLight,
              ),
            ),
            const SizedBox(height: GoogleAIColors.spacing4),
            Text(
              title,
              style: theme.textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: GoogleAIColors.spacing2),
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? GoogleAIColors.textSecondaryDark
                      : GoogleAIColors.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: GoogleAIColors.spacing6),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Mobile Bottom Navigation
  Widget _buildBottomNav(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color:
            isDark ? GoogleAIColors.surfaceDark : GoogleAIColors.surfaceLight,
        border: Border(
          top: BorderSide(
            color:
                isDark ? GoogleAIColors.borderDark : GoogleAIColors.borderLight,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing4,
            vertical: GoogleAIColors.spacing2,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home_rounded,
                label: 'الرئيسية',
                isSelected: true,
                onTap: () {},
              ),
              _buildBottomNavItem(
                icon: Icons.search_rounded,
                label: 'بحث',
                isSelected: false,
                onTap: () => context.push('/search'),
              ),
              _buildBottomNavItem(
                icon: Icons.star_rounded,
                label: 'المفضلة',
                isSelected: false,
                onTap: () => context.push('/favorites'),
              ),
              _buildBottomNavItem(
                icon: Icons.settings_rounded,
                label: 'الإعدادات',
                isSelected: false,
                onTap: () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: GoogleAIColors.spacing3,
          vertical: GoogleAIColors.spacing2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? GoogleAIColors.deepBlue
                  : GoogleAIColors.textSecondaryLight,
            ),
            const SizedBox(height: GoogleAIColors.spacing1),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? GoogleAIColors.deepBlue
                    : GoogleAIColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mobile Drawer
  Widget _buildMobileDrawer(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Drawer(
      backgroundColor:
          isDark ? GoogleAIColors.surfaceDark : GoogleAIColors.surfaceLight,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(GoogleAIColors.spacing4),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          GoogleAIColors.deepBlue,
                          GoogleAIColors.warmPurple
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius:
                          BorderRadius.circular(GoogleAIColors.radiusMd),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: GoogleAIColors.spacing3),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'راصد أم القرى',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'جريدة أم القرى الرسمية',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isDark
                              ? GoogleAIColors.textSecondaryDark
                              : GoogleAIColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Navigation
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  vertical: GoogleAIColors.spacing2,
                ),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    label: 'جميع الأخبار',
                    isSelected: _selectedSourceKey == null,
                    onTap: () {
                      Navigator.pop(context);
                      _selectSource(context, null);
                    },
                    isDark: isDark,
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: GoogleAIColors.spacing4,
                      vertical: GoogleAIColors.spacing2,
                    ),
                    child: Text(
                      'الأقسام',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: GoogleAIColors.textTertiaryLight,
                      ),
                    ),
                  ),
                  ..._sources.map((source) => _buildDrawerItem(
                        context,
                        icon: _getIconData(source.icon),
                        label: source.nameAr,
                        isSelected: _selectedSourceKey == source.id,
                        color: Color(source.colorValue),
                        onTap: () {
                          Navigator.pop(context);
                          _selectSource(context, source.id);
                        },
                        isDark: isDark,
                      )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? color,
  }) {
    final itemColor = color ?? GoogleAIColors.deepBlue;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? itemColor : GoogleAIColors.textSecondaryLight,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          color: isSelected
              ? itemColor
              : (isDark
                  ? GoogleAIColors.textPrimaryDark
                  : GoogleAIColors.textPrimaryLight),
        ),
      ),
      selected: isSelected,
      selectedTileColor: itemColor.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GoogleAIColors.radiusMd),
      ),
      onTap: onTap,
    );
  }

  void _selectSource(BuildContext context, String? sourceKey) {
    setState(() {
      _selectedSourceKey = sourceKey;
    });
    context.read<ArticlesBloc>().add(LoadArticles(sourceKey: sourceKey));
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'gavel':
        return Icons.gavel_rounded;
      case 'verified':
        return Icons.verified_rounded;
      case 'article':
        return Icons.article_rounded;
      case 'description':
        return Icons.description_rounded;
      case 'balance':
        return Icons.balance_rounded;
      case 'account_balance':
        return Icons.account_balance_rounded;
      case 'business':
        return Icons.business_rounded;
      default:
        return Icons.article_rounded;
    }
  }
}
