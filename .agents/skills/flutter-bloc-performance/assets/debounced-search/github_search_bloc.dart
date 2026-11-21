// Template: adapt result/error types and cache policy to the project repository.
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<T> debounceRestartable<T>(Duration duration) => (events, mapper) =>
    restartable<T>().call(events.debounce(duration), mapper);

sealed class GithubSearchEvent {
  const GithubSearchEvent();
}

final class GithubQueryChanged extends GithubSearchEvent {
  const GithubQueryChanged(this.query);
  final String query;
}

enum SearchStatus { idle, loading, success, failure }

final class GithubSearchState extends Equatable {
  const GithubSearchState({this.query = '', this.results = const [], this.status = SearchStatus.idle, this.error});

  final String query;
  final List<GithubSearchResult> results;
  final SearchStatus status;
  final Object? error;

  @override
  List<Object?> get props => [query, results, status, error];
}

class GithubSearchBloc extends Bloc<GithubSearchEvent, GithubSearchState> {
  GithubSearchBloc(this._repository) : super(const GithubSearchState()) {
    on<GithubQueryChanged>(_onQueryChanged,
        transformer: debounceRestartable(const Duration(milliseconds: 300)));
  }

  final GithubRepository _repository;

  Future<void> _onQueryChanged(
    GithubQueryChanged event,
    Emitter<GithubSearchState> emit,
  ) async {
    final query = event.query.trim();
    if (query.isEmpty) {
      emit(const GithubSearchState());
      return;
    }
    emit(GithubSearchState(query: query, status: SearchStatus.loading));
    try {
      final results = await _repository.search(query);
      if (!emit.isDone) {
        emit(GithubSearchState(query: query, results: results, status: SearchStatus.success));
      }
    } on Object catch (error, stackTrace) {
      if (emit.isDone) return;
      addError(error, stackTrace);
      emit(GithubSearchState(query: query, status: SearchStatus.failure, error: error));
    }
  }
}

abstract interface class GithubRepository {
  /// Owns cache lookup, TTL/invalidation, transport, and response mapping.
  Future<List<GithubSearchResult>> search(String normalizedQuery);
}

class GithubSearchResult extends Equatable {
  const GithubSearchResult(this.id, this.name);
  final String id;
  final String name;
  @override
  List<Object?> get props => [id, name];
}
