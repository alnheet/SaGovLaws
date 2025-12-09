import '../../domain/entities/source.dart';
import '../../domain/repositories/sources_repository.dart';
import '../datasources/sources_remote_datasource.dart';

/// Sources Repository Implementation
class SourcesRepositoryImpl implements SourcesRepository {
  final SourcesRemoteDataSource remoteDataSource;

  SourcesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Source>> getSources() async {
    return remoteDataSource.getSources();
  }

  @override
  Future<List<Source>> getEnabledSources() async {
    return remoteDataSource.getEnabledSources();
  }

  @override
  Future<Source?> getSourceById(String id) async {
    return remoteDataSource.getSourceById(id);
  }
}
