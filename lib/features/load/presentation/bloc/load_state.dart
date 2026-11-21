part of 'load_bloc.dart';

/// Basic state for [LoadBloc].
@immutable
sealed class LoadState {
  const LoadState();
}

/// Initial state for [LoadBloc].
final class LoadInitial extends LoadState {
  const LoadInitial();
}

/// Indicates that the loading of some data is happening at the very moment.
final class LoadInProgress extends LoadState {
  const LoadInProgress();
}

/// The retrival of the questions has been completed.
final class LoadQuestionsCompleted extends LoadState {
  final QuestionList questions;

  const LoadQuestionsCompleted({required this.questions});
}

/// The retrival of the answers has been completed.
final class LoadAnswersCompleted extends LoadState {
  final AnswerList answers;

  const LoadAnswersCompleted({required this.answers});
}

/// An error occurred during the data loading process.
final class LoadFailure extends LoadState {
  /// Error message.
  final String message;

  const LoadFailure(this.message);
}

/// An error occurred during the questions loading process.
final class LoadQuestionsFailure extends LoadFailure {
  const LoadQuestionsFailure(super.message);
}

/// An error occurred during the answers loading process.
final class LoadAnswersFailure extends LoadQuestionsFailure {
  const LoadAnswersFailure(super.message);
}
