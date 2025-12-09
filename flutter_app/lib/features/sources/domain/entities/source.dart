import 'package:equatable/equatable.dart';

/// Source Entity - Represents a news category
class Source extends Equatable {
  final String id;
  final String nameAr;
  final String nameEn;
  final int catId;
  final String url;
  final bool enabled;
  final String icon;
  final String color;
  final int order;
  final DateTime? lastSyncAt;
  final int articleCount;
  final String? lastError;

  const Source({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.catId,
    required this.url,
    required this.enabled,
    required this.icon,
    required this.color,
    required this.order,
    this.lastSyncAt,
    this.articleCount = 0,
    this.lastError,
  });

  @override
  List<Object?> get props => [
        id,
        nameAr,
        nameEn,
        catId,
        url,
        enabled,
        icon,
        color,
        order,
        lastSyncAt,
        articleCount,
        lastError,
      ];

  /// Get Material icon data from icon name
  String get iconName => icon;

  /// Get color as Color object
  int get colorValue => int.parse(color.replaceFirst('#', '0xFF'));
}
