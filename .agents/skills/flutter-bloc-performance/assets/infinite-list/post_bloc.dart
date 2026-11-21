// Template: replace Post and PostRepository with project domain types.
import 'package:bloc/bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:stream_transform/stream_transform.dart';

EventTransformer<T> throttleDroppable<T>(Duration duration) => (events, mapper) =>
    droppable<T>().call(events.throttle(duration), mapper);

sealed class PostEvent {
  const PostEvent();
}

final class PostFetched extends PostEvent {
  const PostFetched();
}

final class PostState extends Equatable {
  const PostState({this.posts = const [], this.hasReachedMax = false, this.loading = false, this.error});

  final List<Post> posts;
  final bool hasReachedMax;
  final bool loading;
  final Object? error;

  PostState copyWith({List<Post>? posts, bool? hasReachedMax, bool? loading, Object? error}) =>
      PostState(
        posts: posts ?? this.posts,
        hasReachedMax: hasReachedMax ?? this.hasReachedMax,
        loading: loading ?? this.loading,
        error: error,
      );

  @override
  List<Object?> get props => [posts, hasReachedMax, loading, error];
}

class PostBloc extends Bloc<PostEvent, PostState> {
  PostBloc(this._repository) : super(const PostState()) {
    on<PostFetched>(_onFetched, transformer: throttleDroppable(const Duration(milliseconds: 100)));
  }

  final PostRepository _repository;

  Future<void> _onFetched(PostFetched event, Emitter<PostState> emit) async {
    if (state.hasReachedMax) return;
    emit(state.copyWith(loading: true, error: null));
    try {
      final next = await _repository.fetchPosts(offset: state.posts.length, limit: 20);
      if (emit.isDone) return;
      emit(state.copyWith(
        posts: [...state.posts, ...next],
        hasReachedMax: next.isEmpty,
        loading: false,
      ));
    } on Object catch (error, stackTrace) {
      addError(error, stackTrace);
      if (!emit.isDone) emit(state.copyWith(loading: false, error: error));
    }
  }
}

abstract interface class PostRepository {
  Future<List<Post>> fetchPosts({required int offset, required int limit});
}

class Post extends Equatable {
  const Post(this.id, this.title);
  final String id;
  final String title;
  @override
  List<Object?> get props => [id, title];
}
