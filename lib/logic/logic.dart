import 'dart:math';

class CasualityManager {
  final int seed;
  final int playerNumber;
  final Random randomQuestionCard;
  final Random randomAnswerCard;
  static const int totalPlayers = 4;

  CasualityManager({
    required this.seed,
    required this.playerNumber,
    required this.randomQuestionCard,
    required this.randomAnswerCard,
  });
}
