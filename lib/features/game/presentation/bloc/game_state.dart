part of 'game_bloc.dart';

/// Base state for [GameBloc].
@immutable
sealed class GameState {
  const GameState();
}

/// Initial state before the first round is prepared.
final class RoundStart extends GameState {}

/// Round data is loaded and waiting for card selection.
final class RoundReady extends GameState {}

/// Single-answer turn completed with the selected [card].
final class FirstCardCliked extends GameState {
  final CardAH card;

  const FirstCardCliked({required this.card});
}

/// Two-answer turn completed with [card1] and [card2].
final class SecondCardCliked extends GameState {
  final CardAH card1;
  final CardAH card2;

  const SecondCardCliked({
    required this.card1,
    required this.card2,
  });
}

/// The answer cards for the given IDs have been retrieved.
final class AnswerCardsLoaded extends GameState {
  final AnswerList answers;

  const AnswerCardsLoaded({required this.answers});
}

/// The operation of accessing or validating cards returned a failure.
final class LoadFailure extends GameState {
  /// Error description explaining why loading or validation failed.
  final String message;

  const LoadFailure([this.message = '']);
}
