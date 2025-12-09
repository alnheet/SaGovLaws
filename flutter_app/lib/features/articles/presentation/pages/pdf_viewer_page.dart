import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// PDF Viewer Page - displays PDF documents in-app
class PdfViewerPage extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerPage({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final PdfViewerController _pdfController = PdfViewerController();
  bool _isLoading = true;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 0;

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          // Page indicator
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
          // Zoom in
          IconButton(
            icon: const Icon(Icons.zoom_in),
            onPressed: () {
              _pdfController.zoomLevel = _pdfController.zoomLevel + 0.25;
            },
            tooltip: 'تكبير',
          ),
          // Zoom out
          IconButton(
            icon: const Icon(Icons.zoom_out),
            onPressed: () {
              if (_pdfController.zoomLevel > 0.5) {
                _pdfController.zoomLevel = _pdfController.zoomLevel - 0.25;
              }
            },
            tooltip: 'تصغير',
          ),
          // Jump to page
          IconButton(
            icon: const Icon(Icons.find_in_page),
            onPressed: _showGoToPageDialog,
            tooltip: 'انتقال لصفحة',
          ),
        ],
      ),
      body: Stack(
        children: [
          SfPdfViewer.network(
            widget.pdfUrl,
            key: _pdfViewerKey,
            controller: _pdfController,
            canShowScrollHead: true,
            canShowScrollStatus: true,
            enableDoubleTapZooming: true,
            enableTextSelection: true,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoading = false;
                _totalPages = details.document.pages.count;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoading = false;
                _error = details.description;
              });
            },
            onPageChanged: (details) {
              setState(() {
                _currentPage = details.newPageNumber;
              });
            },
          ),
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.white.withValues(alpha: 0.8),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('جاري تحميل الملف...'),
                  ],
                ),
              ),
            ),
          // Error state
          if (_error != null)
            Container(
              color: Colors.white,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'تعذر تحميل الملف',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          // Force rebuild
                          (context as Element).markNeedsBuild();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      // Bottom navigation bar for quick actions
      bottomNavigationBar: _totalPages > 0
          ? BottomAppBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // First page
                  IconButton(
                    icon: const Icon(Icons.first_page),
                    onPressed: () => _pdfController.jumpToPage(1),
                    tooltip: 'الصفحة الأولى',
                  ),
                  // Previous page
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _currentPage > 1
                        ? () => _pdfController.previousPage()
                        : null,
                    tooltip: 'الصفحة السابقة',
                  ),
                  // Page slider
                  Expanded(
                    child: Slider(
                      value: _currentPage.toDouble(),
                      min: 1,
                      max: _totalPages.toDouble(),
                      divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                      onChanged: (value) {
                        _pdfController.jumpToPage(value.toInt());
                      },
                    ),
                  ),
                  // Next page
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _currentPage < _totalPages
                        ? () => _pdfController.nextPage()
                        : null,
                    tooltip: 'الصفحة التالية',
                  ),
                  // Last page
                  IconButton(
                    icon: const Icon(Icons.last_page),
                    onPressed: () => _pdfController.jumpToPage(_totalPages),
                    tooltip: 'الصفحة الأخيرة',
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _showGoToPageDialog() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('انتقال لصفحة'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'رقم الصفحة (1 - $_totalPages)',
            border: const OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(controller.text);
              if (page != null && page >= 1 && page <= _totalPages) {
                _pdfController.jumpToPage(page);
                Navigator.pop(context);
              }
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    );
  }
}
