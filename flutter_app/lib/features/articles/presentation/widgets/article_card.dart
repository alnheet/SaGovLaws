import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/google_ai_colors.dart';
import '../../domain/entities/article.dart';

/// Article card widget - Google AI Studio style
/// Clean, density-aware with high border-radius and subtle shadows
class ArticleCard extends StatelessWidget {
  final Article article;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle;

  const ArticleCard({
    super.key,
    required this.article,
    this.isFavorite = false,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final sourceColor = GoogleAIColors.sourceColors[article.sourceKey] ??
        GoogleAIColors.deepBlue;
    final sourceColorLight =
        GoogleAIColors.sourceColorsLight[article.sourceKey] ??
            GoogleAIColors.deepBlueMuted;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: GoogleAIColors.spacing4,
        vertical: GoogleAIColors.spacing2,
      ),
      decoration: BoxDecoration(
        color:
            isDark ? GoogleAIColors.surfaceDark : GoogleAIColors.surfaceLight,
        borderRadius: BorderRadius.circular(GoogleAIColors.radiusXl),
        border: Border.all(
          color:
              isDark ? GoogleAIColors.borderDark : GoogleAIColors.borderLight,
          width: 1,
        ),
        boxShadow: isDark ? null : GoogleAIColors.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(GoogleAIColors.radiusXl),
        child: InkWell(
          onTap: () => context.push('/home/article/${article.id}'),
          borderRadius: BorderRadius.circular(GoogleAIColors.radiusXl),
          child: Padding(
            padding: const EdgeInsets.all(GoogleAIColors.spacing5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: Source chip + Date
                Row(
                  children: [
                    // Source Chip
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GoogleAIColors.spacing3,
                          vertical: GoogleAIColors.spacing1,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? sourceColor.withValues(alpha: 0.2)
                              : sourceColorLight,
                          borderRadius:
                              BorderRadius.circular(GoogleAIColors.radiusFull),
                        ),
                        child: Text(
                          article.sourceNameAr,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: sourceColor,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Date
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: isDark
                              ? GoogleAIColors.textTertiaryDark
                              : GoogleAIColors.textTertiaryLight,
                        ),
                        const SizedBox(width: GoogleAIColors.spacing1),
                        Text(
                          article.publishDateRaw,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: isDark
                                ? GoogleAIColors.textTertiaryDark
                                : GoogleAIColors.textTertiaryLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: GoogleAIColors.spacing4),

                // Title
                Text(
                  article.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),

                // Excerpt
                if (article.excerpt != null) ...[
                  const SizedBox(height: GoogleAIColors.spacing2),
                  Text(
                    article.excerpt!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? GoogleAIColors.textSecondaryDark
                          : GoogleAIColors.textSecondaryLight,
                      height: 1.5,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],

                const SizedBox(height: GoogleAIColors.spacing4),

                // Footer Actions
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // Open in Browser
                      _ActionButton(
                        icon: Icons.open_in_new_rounded,
                        label: 'المصدر',
                        onPressed: () => _openUrl(article.url),
                        isDark: isDark,
                      ),

                      const SizedBox(width: GoogleAIColors.spacing2),

                      // PDF button (if available)
                      if (article.hasPdf) ...[
                        _ActionButton(
                          icon: Icons.picture_as_pdf_rounded,
                          label: 'PDF',
                          color: GoogleAIColors.coral,
                          onPressed: () {
                            if (article.pdfUrl != null) {
                              _openUrl(article.pdfUrl!);
                            }
                          },
                          isDark: isDark,
                        ),
                        const SizedBox(width: GoogleAIColors.spacing2),
                      ],

                      const Spacer(),

                      // Favorite button
                      Material(
                        color: Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(GoogleAIColors.radiusFull),
                        child: InkWell(
                          onTap: onFavoriteToggle,
                          borderRadius:
                              BorderRadius.circular(GoogleAIColors.radiusFull),
                          child: Padding(
                            padding:
                                const EdgeInsets.all(GoogleAIColors.spacing2),
                            child: Icon(
                              isFavorite
                                  ? Icons.star_rounded
                                  : Icons.star_outline_rounded,
                              color: isFavorite
                                  ? GoogleAIColors.amber
                                  : (isDark
                                      ? GoogleAIColors.textTertiaryDark
                                      : GoogleAIColors.textTertiaryLight),
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Compact action button for card footer
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool isDark;
  final Color? color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    required this.isDark,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? GoogleAIColors.deepBlue;
    final bgColor = isDark
        ? buttonColor.withValues(alpha: 0.15)
        : buttonColor.withValues(alpha: 0.08);

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(GoogleAIColors.radiusFull),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GoogleAIColors.spacing3,
            vertical: GoogleAIColors.spacing1 + 2,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: buttonColor,
              ),
              const SizedBox(width: GoogleAIColors.spacing1),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: buttonColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
