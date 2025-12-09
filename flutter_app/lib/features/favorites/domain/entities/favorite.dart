import 'package:equatable/equatable.dart';

/// Favorite Entity
class Favorite extends Equatable {
  final String articleId;
  final String sourceKey;
  final DateTime addedAt;

  const Favorite({
    required this.articleId,
    required this.sourceKey,
    required this.addedAt,
  });

  @override
  List<Object?> get props => [articleId, sourceKey, addedAt];
}
