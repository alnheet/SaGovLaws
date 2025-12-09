import 'package:equatable/equatable.dart';

/// Article Entity - Core business model
class Article extends Equatable {
  final String id;
  final String originalId;
  final String sourceKey;
  final String sourceNameAr;
  final int catId;
  final String title;
  final String? contentHtml;
  final String? contentPlain;
  final String? excerpt;
  final String publishDateRaw;
  final String? publishDateGregorian;
  final DateTime? publishDateIso;
  final String url;
  final String? pdfUrl;
  final bool hasPdf;
  final DateTime scrapedAt;
  final DateTime updatedAt;
  final List<String>? tags;

  const Article({
    required this.id,
    required this.originalId,
    required this.sourceKey,
    required this.sourceNameAr,
    required this.catId,
    required this.title,
    this.contentHtml,
    this.contentPlain,
    this.excerpt,
    required this.publishDateRaw,
    this.publishDateGregorian,
    this.publishDateIso,
    required this.url,
    this.pdfUrl,
    required this.hasPdf,
    required this.scrapedAt,
    required this.updatedAt,
    this.tags,
  });

  @override
  List<Object?> get props => [
        id,
        originalId,
        sourceKey,
        sourceNameAr,
        catId,
        title,
        contentHtml,
        contentPlain,
        excerpt,
        publishDateRaw,
        publishDateGregorian,
        publishDateIso,
        url,
        pdfUrl,
        hasPdf,
        scrapedAt,
        updatedAt,
        tags,
      ];

  /// Create a copy with updated fields
  Article copyWith({
    String? id,
    String? originalId,
    String? sourceKey,
    String? sourceNameAr,
    int? catId,
    String? title,
    String? contentHtml,
    String? contentPlain,
    String? excerpt,
    String? publishDateRaw,
    String? publishDateGregorian,
    DateTime? publishDateIso,
    String? url,
    String? pdfUrl,
    bool? hasPdf,
    DateTime? scrapedAt,
    DateTime? updatedAt,
    List<String>? tags,
  }) {
    return Article(
      id: id ?? this.id,
      originalId: originalId ?? this.originalId,
      sourceKey: sourceKey ?? this.sourceKey,
      sourceNameAr: sourceNameAr ?? this.sourceNameAr,
      catId: catId ?? this.catId,
      title: title ?? this.title,
      contentHtml: contentHtml ?? this.contentHtml,
      contentPlain: contentPlain ?? this.contentPlain,
      excerpt: excerpt ?? this.excerpt,
      publishDateRaw: publishDateRaw ?? this.publishDateRaw,
      publishDateGregorian: publishDateGregorian ?? this.publishDateGregorian,
      publishDateIso: publishDateIso ?? this.publishDateIso,
      url: url ?? this.url,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      hasPdf: hasPdf ?? this.hasPdf,
      scrapedAt: scrapedAt ?? this.scrapedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tags: tags ?? this.tags,
    );
  }
}
