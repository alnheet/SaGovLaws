import '../entities/source.dart';

/// Sources Repository Interface
abstract class SourcesRepository {
  /// Get all sources
  Future<List<Source>> getSources();

  /// Get enabled sources only
  Future<List<Source>> getEnabledSources();

  /// Get source by ID
  Future<Source?> getSourceById(String id);
}
