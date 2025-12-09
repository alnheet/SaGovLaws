import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/article.dart';

/// Service for exporting articles as images
class ArticleExportService {
  /// Captures a widget as an image and allows sharing
  static Future<void> exportAsImage({
    required BuildContext context,
    required GlobalKey repaintBoundaryKey,
    required Article article,
  }) async {
    try {
      // Show loading indicator
      _showLoadingDialog(context);

      // Capture the widget
      final Uint8List? imageBytes = await _captureWidget(repaintBoundaryKey);

      // Dismiss loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      if (imageBytes == null) {
        if (context.mounted) {
          _showErrorSnackBar(context, 'فشل في التقاط الصورة');
        }
        return;
      }

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          'article_${article.id}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: article.title,
        subject: 'مشاركة مقال',
      );
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorSnackBar(context, 'حدث خطأ: $e');
      }
    }
  }

  /// Captures a widget to image bytes
  static Future<Uint8List?> _captureWidget(GlobalKey key) async {
    try {
      final RenderRepaintBoundary? boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) return null;

      // Wait for widget to be fully rendered
      await Future.delayed(const Duration(milliseconds: 100));

      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) return null;

      return byteData.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capturing widget: $e');
      return null;
    }
  }

  /// Shows a loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('جاري تصدير الصورة...'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Shows an error snackbar
  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// Widget that wraps article content for export
class ExportableArticleContent extends StatelessWidget {
  final Article article;
  final GlobalKey repaintKey;

  const ExportableArticleContent({
    super.key,
    required this.article,
    required this.repaintKey,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RepaintBoundary(
      key: repaintKey,
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with source
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    article.sourceKey,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  article.publishDateRaw,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Title
            Text(
              article.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Content preview
            if (article.contentPlain != null)
              Text(
                article.contentPlain!.length > 500
                    ? '${article.contentPlain!.substring(0, 500)}...'
                    : article.contentPlain!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                ),
              ),

            const SizedBox(height: 24),

            // Footer with app branding
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.newspaper, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 8),
                Text(
                  'تطبيق رصد',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
