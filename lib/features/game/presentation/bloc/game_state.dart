part of 'game_bloc.dart';

@immutable
sealed class GameState {
  const GameState();
}

final class RoundStart extends GameState {}

final class RoundReady extends GameState {}

final class FirstCardCliked extends GameState {
  final CardAH card;

  const FirstCardCliked({required this.card});
}

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

/// The operation of accessing a card returned a failure
final class LoadFailure extends GameState {}
