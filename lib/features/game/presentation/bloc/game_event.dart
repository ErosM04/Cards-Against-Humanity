part of 'game_bloc.dart';

@immutable
sealed class GameEvent {}

final class GameClicked extends GameEvent {
  final CardAH card;

  GameClicked(this.card);
}
