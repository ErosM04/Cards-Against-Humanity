import 'package:cards_against_humanity/core/entities/data/answer_list.dart';

/// Stores the data ralated to the current state of the game.
class GameState {
  final int playerNumber;
  final int totalPlayers;
  final AnswerList hand;
  int totalRounds;
  int playedRounds;
  int score;

  GameState(
      {required this.playerNumber,
      required this.totalPlayers,
      required this.hand})
      : totalRounds = 0,
        playedRounds = -1,
        score = 0;

  // TODO: Implement copyWith() for deep copy
}
