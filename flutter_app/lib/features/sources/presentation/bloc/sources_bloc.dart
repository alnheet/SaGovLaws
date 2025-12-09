import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/source.dart';
import '../../domain/repositories/sources_repository.dart';

// Events
abstract class SourcesEvent extends Equatable {
  const SourcesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSources extends SourcesEvent {}

// State
class SourcesState extends Equatable {
  final SourcesStatus status;
  final List<Source> sources;
  final String? error;

  const SourcesState({
    this.status = SourcesStatus.initial,
    this.sources = const [],
    this.error,
  });

  SourcesState copyWith({
    SourcesStatus? status,
    List<Source>? sources,
    String? error,
  }) {
    return SourcesState(
      status: status ?? this.status,
      sources: sources ?? this.sources,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, sources, error];
}

enum SourcesStatus {
  initial,
  loading,
  success,
  failure,
}

// BLoC
class SourcesBloc extends Bloc<SourcesEvent, SourcesState> {
  final SourcesRepository repository;

  SourcesBloc({required this.repository}) : super(const SourcesState()) {
    on<LoadSources>(_onLoadSources);
  }

  Future<void> _onLoadSources(
    LoadSources event,
    Emitter<SourcesState> emit,
  ) async {
    emit(state.copyWith(status: SourcesStatus.loading));

    try {
      final sources = await repository.getEnabledSources();
      emit(state.copyWith(
        status: SourcesStatus.success,
        sources: sources,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: SourcesStatus.failure,
        error: e.toString(),
      ));
    }
  }
}
