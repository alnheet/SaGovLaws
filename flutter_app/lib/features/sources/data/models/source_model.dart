import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/source.dart' as entities;

/// Source Model for data layer
class SourceModel extends entities.Source {
  const SourceModel({
    required super.id,
    required super.nameAr,
    required super.nameEn,
    required super.catId,
    required super.url,
    required super.enabled,
    required super.icon,
    required super.color,
    required super.order,
    super.lastSyncAt,
    super.articleCount,
    super.lastError,
  });

  factory SourceModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SourceModel(
      id: data['id'] as String,
      nameAr: data['name_ar'] as String,
      nameEn: data['name_en'] as String,
      catId: data['cat_id'] as int,
      url: data['url'] as String,
      enabled: data['enabled'] as bool? ?? true,
      icon: data['icon'] as String? ?? 'article',
      color: data['color'] as String? ?? '#1976D2',
      order: data['order'] as int? ?? 0,
      lastSyncAt: (data['last_sync_at'] as Timestamp?)?.toDate(),
      articleCount: data['article_count'] as int? ?? 0,
      lastError: data['last_error'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name_ar': nameAr,
      'name_en': nameEn,
      'cat_id': catId,
      'url': url,
      'enabled': enabled,
      'icon': icon,
      'color': color,
      'order': order,
      'last_sync_at': lastSyncAt,
      'article_count': articleCount,
      'last_error': lastError,
    };
  }
}

/// Default sources for offline/initialization
class DefaultSources {
  static const List<SourceModel> sources = [
    SourceModel(
      id: 'cabinet_decisions',
      nameAr: 'قرارات مجلس الوزراء',
      nameEn: 'Cabinet Decisions',
      catId: 9,
      url: 'https://uqn.gov.sa/category?cat=9',
      enabled: true,
      icon: 'gavel',
      color: '#1976D2',
      order: 1,
    ),
    SourceModel(
      id: 'royal_orders',
      nameAr: 'أوامر ملكية',
      nameEn: 'Royal Orders',
      catId: 7,
      url: 'https://uqn.gov.sa/category?cat=7',
      enabled: true,
      icon: 'verified',
      color: '#7B1FA2',
      order: 2,
    ),
    SourceModel(
      id: 'royal_decrees',
      nameAr: 'مراسيم ملكية',
      nameEn: 'Royal Decrees',
      catId: 8,
      url: 'https://uqn.gov.sa/category?cat=8',
      enabled: true,
      icon: 'article',
      color: '#C2185B',
      order: 3,
    ),
    SourceModel(
      id: 'decisions_regulations',
      nameAr: 'قرارات وأنظمة',
      nameEn: 'Decisions & Regulations',
      catId: 6,
      url: 'https://uqn.gov.sa/category?cat=6',
      enabled: true,
      icon: 'description',
      color: '#00796B',
      order: 4,
    ),
    SourceModel(
      id: 'laws_regulations',
      nameAr: 'لوائح وأنظمة',
      nameEn: 'Laws & Regulations',
      catId: 11,
      url: 'https://uqn.gov.sa/category?cat=11',
      enabled: true,
      icon: 'balance',
      color: '#F57C00',
      order: 5,
    ),
    SourceModel(
      id: 'ministerial_decisions',
      nameAr: 'قرارات وزارية',
      nameEn: 'Ministerial Decisions',
      catId: 10,
      url: 'https://uqn.gov.sa/category?cat=10',
      enabled: true,
      icon: 'account_balance',
      color: '#5D4037',
      order: 6,
    ),
    SourceModel(
      id: 'authorities',
      nameAr: 'هيئات',
      nameEn: 'Authorities',
      catId: 12,
      url: 'https://uqn.gov.sa/category?cat=12',
      enabled: true,
      icon: 'business',
      color: '#455A64',
      order: 7,
    ),
  ];
}
