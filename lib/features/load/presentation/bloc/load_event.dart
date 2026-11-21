part of 'load_bloc.dart';

/// Basic event for [LoadBloc].
@immutable
sealed class LoadEvent {
  const LoadEvent();
}

/// Triggers the questions retrival process.
final class LoadQuestionsStart extends LoadEvent {
  const LoadQuestionsStart();
}

/// Triggers the answers retrival process.
final class LoadAnswersStart extends LoadEvent {
  const LoadAnswersStart();
}
