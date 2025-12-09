import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/article.dart';

/// Article Model - Data layer representation
/// Handles JSON/Firestore serialization
class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.originalId,
    required super.sourceKey,
    required super.sourceNameAr,
    required super.catId,
    required super.title,
    super.contentHtml,
    super.contentPlain,
    super.excerpt,
    required super.publishDateRaw,
    super.publishDateGregorian,
    super.publishDateIso,
    required super.url,
    super.pdfUrl,
    required super.hasPdf,
    required super.scrapedAt,
    required super.updatedAt,
    super.tags,
  });

  /// Create from Firestore document
  factory ArticleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ArticleModel.fromMap(data);
  }

  /// Create from Map
  factory ArticleModel.fromMap(Map<String, dynamic> map) {
    return ArticleModel(
      id: map['id'] as String,
      originalId: map['original_id'] as String,
      sourceKey: map['source_key'] as String,
      sourceNameAr: map['source_name_ar'] as String,
      catId: map['cat_id'] as int,
      title: map['title'] as String,
      contentHtml: map['content_html'] as String?,
      contentPlain: map['content_plain'] as String?,
      excerpt: map['excerpt'] as String?,
      publishDateRaw: map['publish_date_raw'] as String,
      publishDateGregorian: map['publish_date_gregorian'] as String?,
      publishDateIso: _parseTimestamp(map['publish_date_iso']),
      url: map['url'] as String,
      pdfUrl: map['pdf_url'] as String?,
      hasPdf: map['has_pdf'] as bool? ?? false,
      scrapedAt: _parseTimestamp(map['scraped_at']) ?? DateTime.now(),
      updatedAt: _parseTimestamp(map['updated_at']) ?? DateTime.now(),
      tags: (map['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'original_id': originalId,
      'source_key': sourceKey,
      'source_name_ar': sourceNameAr,
      'cat_id': catId,
      'title': title,
      'content_html': contentHtml,
      'content_plain': contentPlain,
      'excerpt': excerpt,
      'publish_date_raw': publishDateRaw,
      'publish_date_gregorian': publishDateGregorian,
      'publish_date_iso': publishDateIso?.toIso8601String(),
      'url': url,
      'pdf_url': pdfUrl,
      'has_pdf': hasPdf,
      'scraped_at': scrapedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'tags': tags,
    };
  }

  /// Convert from Entity to Model
  factory ArticleModel.fromEntity(Article article) {
    return ArticleModel(
      id: article.id,
      originalId: article.originalId,
      sourceKey: article.sourceKey,
      sourceNameAr: article.sourceNameAr,
      catId: article.catId,
      title: article.title,
      contentHtml: article.contentHtml,
      contentPlain: article.contentPlain,
      excerpt: article.excerpt,
      publishDateRaw: article.publishDateRaw,
      publishDateGregorian: article.publishDateGregorian,
      publishDateIso: article.publishDateIso,
      url: article.url,
      pdfUrl: article.pdfUrl,
      hasPdf: article.hasPdf,
      scrapedAt: article.scrapedAt,
      updatedAt: article.updatedAt,
      tags: article.tags,
    );
  }

  /// Parse Firestore Timestamp
  static DateTime? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
