import 'dart:math';

class CasualityManager {
  final int seed;
  final int playerNumber;
  final Random randomQuestionCard;
  final Random randomAnswerCard;
  final List<List> questionList;
  final List<String> answerList;
  static const int totalPlayers = 4;

  CasualityManager({
    required this.seed,
    required this.playerNumber,
    required this.randomQuestionCard,
    required this.randomAnswerCard,
    required this.questionList,
    required this.answerList,
  });

  String drawAnswerCard() {
    int position = 0;
    for (var i = 0; i < totalPlayers; i++) {
      if (playerNumber - 1 == i) {
        position = randomAnswerCard.nextInt(answerList.length);
      }
      randomAnswerCard.nextInt(answerList.length);
    }
    return answerList[position];
  }

  String drawQuestionCard() =>
      questionList[randomQuestionCard.nextInt(questionList.length)][0];
}
