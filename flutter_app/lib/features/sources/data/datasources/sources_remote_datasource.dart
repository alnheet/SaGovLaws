import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/source_model.dart';

/// Sources remote data source interface
abstract class SourcesRemoteDataSource {
  Future<List<SourceModel>> getSources();
  Future<List<SourceModel>> getEnabledSources();
  Future<SourceModel?> getSourceById(String id);
}

/// Firestore implementation
class SourcesRemoteDataSourceImpl implements SourcesRemoteDataSource {
  final FirebaseFirestore firestore;

  SourcesRemoteDataSourceImpl(this.firestore);

  @override
  Future<List<SourceModel>> getSources() async {
    try {
      final snapshot = await firestore
          .collection('sources')
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        // Return default sources if collection is empty
        return DefaultSources.sources;
      }

      return snapshot.docs.map(SourceModel.fromFirestore).toList();
    } catch (e) {
      // Return default sources on error
      return DefaultSources.sources;
    }
  }

  @override
  Future<List<SourceModel>> getEnabledSources() async {
    try {
      final snapshot = await firestore
          .collection('sources')
          .where('enabled', isEqualTo: true)
          .orderBy('order')
          .get();

      if (snapshot.docs.isEmpty) {
        return DefaultSources.sources.where((s) => s.enabled).toList();
      }

      return snapshot.docs.map(SourceModel.fromFirestore).toList();
    } catch (e) {
      return DefaultSources.sources.where((s) => s.enabled).toList();
    }
  }

  @override
  Future<SourceModel?> getSourceById(String id) async {
    try {
      final doc = await firestore.collection('sources').doc(id).get();
      if (!doc.exists) {
        return DefaultSources.sources.firstWhere(
          (s) => s.id == id,
          orElse: () => throw Exception('Source not found'),
        );
      }
      return SourceModel.fromFirestore(doc);
    } catch (e) {
      try {
        return DefaultSources.sources.firstWhere((s) => s.id == id);
      } catch (_) {
        return null;
      }
    }
  }
}
