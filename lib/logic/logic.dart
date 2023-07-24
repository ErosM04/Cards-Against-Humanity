import 'dart:math';

class CasualityManager {
  final int seed;
  final int playerNumber;
  static const int totalPlayers = 4;
  final Random randomQuestionCard;
  final Random randomAnswerCard;
  final List<List> questionList;
  final List<String> answerList;
  final List<String> _hand = [];
  static final List<String> selectedCards = [];
  String _actualQuestion = '';
  static int answerNeeded = 0;
  int _round = 0;

  CasualityManager({
    required this.seed,
    required this.playerNumber,
    required this.randomQuestionCard,
    required this.randomAnswerCard,
    required this.questionList,
    required this.answerList,
  }) {
    fillHand();
    drawQuestionCard();
  }

  int get round => _round;

  List<String> get hand => _hand;

  String get question => _actualQuestion;

  void fillHand() {
    if (_hand.isEmpty) {
      _round = 0;
      for (var i = 0; i < 10; i++) {
        _drawAnswerCard();
      }
    } else if (_hand.isNotEmpty && _hand.length < 10) {
      for (var i = _hand.length; i <= 10; i++) {
        _drawAnswerCard();
      }
    }
  }

  void useCard(String cardText) => _hand.remove(cardText);

  void _drawAnswerCard() {
    int position = 0;
    for (var i = 0; i < totalPlayers; i++) {
      if (playerNumber - 1 == i) {
        position = randomAnswerCard.nextInt(answerList.length);
      }
      randomAnswerCard.nextInt(answerList.length);
    }
    _hand.add('$position - ${answerList[position]}');
  }

  List<String> revealAnswerCards(List<int> numbers) =>
      List.generate(numbers.length, (index) => answerList[numbers[index]]);

  void drawQuestionCard() {
    _round++;
    int position = randomQuestionCard.nextInt(questionList.length);
    _actualQuestion = questionList[position][0];
    answerNeeded = questionList[position][1];
  }
}
