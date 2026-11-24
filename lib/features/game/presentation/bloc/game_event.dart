part of 'game_bloc.dart';

/// Base event for [GameBloc].
@immutable
sealed class GameEvent {
  const GameEvent();
}

/// Used to draw cards.
final class StartRound extends GameEvent {
  /// Determines whether this is a turn played as the Master or as a normal Player.
  final bool isMaster;

  const StartRound({required this.isMaster});
}

/// Used to retrive answer cards based on given ids.
final class AnswerCardsRequested extends GameEvent {
  final List<int> ids;

  const AnswerCardsRequested({required this.ids});
}

/// Dispatched when the player taps an answer [card] in their hand.
final class CardClicked extends GameEvent {
  final CardAH card;

  const CardClicked(this.card);
}

/// Records a round win and increments the player's score.
final class RoundWon extends GameEvent {
  const RoundWon();
}

/// Records a round loss and clears the current card selection.
final class RoundLost extends GameEvent {
  const RoundLost();
}
