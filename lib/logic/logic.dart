import 'dart:math';

/// Used to manage the logic of the game, such as random draws, score, rounds, hand...
class CasualityManager {
  final int seed;
  final int playerNumber;
  final int totalPlayers;
  final Random randomQuestionCard;
  final Random randomAnswerCard;
  final List<List> questionList;
  final List<String> answerList;
  final List<String> _hand = [];
  static final List<String> selectedCards = [];
  String _actualQuestion = '';
  static int answerNeeded = 0;
  int _score = 0;
  int _round = 0;

  CasualityManager({
    required this.seed,
    required this.playerNumber,
    this.totalPlayers = 4,
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

  int get score => _score;

  /// If the ``[hand]`` is empty proceed to fill it and sets the ``[round]`` to 0.
  /// Else if the ``[hand]`` has less then adds the remaining cards.
  void fillHand() {
    if (_hand.isEmpty) {
      _round = 0;
      for (var i = 0; i < 10; i++) {
        _drawAnswerCard();
      }
    } else if (_hand.isNotEmpty && _hand.length < 10) {
      for (var i = _hand.length; i < 10; i++) {
        _drawAnswerCard();
      }
    }
  }

  /// This method has to be used every time an answer card is used to complete the question card. Simply removes it from the ``[hand]``.
  void useCard(String cardText) => _hand.remove(cardText);

  /// Extract n-``[totalPlayers]`` random answer card from the ``[answerList]`` and adds to the ``[hand]`` only the i-``[playerNumber]`` card.
  /// Meaning that if there are 4 players and the user is the 3th player, extracts 4 cards and adds to the hand the 3th.
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

  /// Returns a list of answer cards, but without the id. E.g. "104 - Dio" --> "Dio".
  List<String> revealAnswerCards(List<int> numbers) =>
      List.generate(numbers.length, (index) => answerList[numbers[index]]);

  /// Pick a random question card from ``[questionList]``, and saves the text in ``[question]`` and the number of empty spaces to fill in ``[answerNeeded]``.
  /// Also increments the [round]. At the end of the method, the last time the question card is accessed it's also removed from ``[questionList]`` to avoid
  /// reusing the same card over and over
  void drawQuestionCard() {
    _round++;
    int position = randomQuestionCard.nextInt(questionList.length);
    _actualQuestion = questionList[position][0];
    answerNeeded = questionList.removeAt(position)[1];
  }

  /// Used when a round is won. Increase the ``[score]`` and clears ``[selectedCards]``.
  void won() => {_score++, _cleanSelectedCard()};

  /// Used when a round is lost. Clears ``[selectedCards]``.
  void lost() => _cleanSelectedCard();

  /// Clears ``[selectedCards]``.
  void _cleanSelectedCard() => CasualityManager.selectedCards.clear();
}
