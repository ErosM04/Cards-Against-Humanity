part of 'load_bloc.dart';

@immutable
sealed class LoadState {
  const LoadState();
}

final class LoadInitial extends LoadState {
  const LoadInitial();
}

final class LoadInProgress extends LoadState {
  const LoadInProgress();
}

final class LoadCompleted extends LoadState {
  final List<List<String>> questions;
  final List<String> answers;

  const LoadCompleted({required this.questions, required this.answers});
}

final class LoadFailure extends LoadState {
  final String message;

  const LoadFailure(this.message);
}

final class LoadQuestionsFailure extends LoadFailure {
  const LoadQuestionsFailure(super.message);
}

final class LoadAnswersFailure extends LoadQuestionsFailure {
  const LoadAnswersFailure(super.message);
}
