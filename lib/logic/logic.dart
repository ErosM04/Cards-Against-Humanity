import 'dart:math';

/// Used to manage the logic of the game, such as random draws, score, rounds, hand...
class CasualityManager {
  /// The seed use by the ``[Random]`` object to draw cards.
  final int seed;

  /// The dpecific number of the player between 0 and ``[totalPlayers]``.
  final int playerNumber;

  /// The total number of players (3-20).
  final int totalPlayers;

  /// The object used to obtain a random number (corresponding to an answer card) from ``[answerList]``.
  final Random _randomQuestionCard;

  /// The object used to obtain a random number (corresponding to an question card) from ``[questionList]``.
  final Random _randomAnswerCard;

  /// The list of questions, with each question being a List containg the question [String] and n [int] with the amount
  /// of answers needed to complete it. E.g. ``["________ non saranno più gli stessi dopo ________.", 2]``.
  final List<List> questionList;

  /// The list of answers, with each being a [String].
  final List<String> answerList;

  /// The player hand, with 10 answer cards that he/she can choose to complete a question card.
  final List<String> _hand = [];

  /// List of the cards selected by the player in the current round.
  static final List<String> selectedCards = [];

  /// The question card that needs to be completed in the current round.
  String _actualQuestion = '';

  /// The amount of answers needed to complete the question of the current round.
  static int _answersNeeded = 0;

  /// The score of the player.
  int _score = 0;

  /// The toal round of the match.
  int _round = 0;

  /// The amount of rounds that the player has played (excluding those played as the Master).
  int _playedRounds = -1;

  CasualityManager({
    required this.seed,
    required this.playerNumber,
    this.totalPlayers = 3,
    required this.questionList,
    required this.answerList,
  })  : _randomAnswerCard = Random(seed),
        _randomQuestionCard = Random(seed + 1) {
    fillHand();
    drawQuestionCard();
  }

  /// The toal round of the match.
  int get round => _round;

  /// The player hand, with 10 answer cards that he/she can choose to complete a question card.
  List<String> get hand => _hand;

  /// The question card that needs to be completed in the current round.
  String get question => _actualQuestion;

  /// The amount of answers needed to complete the question of the current round.
  static int get answersNeeded => _answersNeeded;

  /// The score of the player.
  int get score => _score;

  /// The amount of rounds that the player has played (excluding those played as the Master).
  int get playedRounds => _playedRounds;

  /// If the ``[hand]`` is empty proceed to fill it and sets the ``[round]`` to 0.
  /// Else if the ``[hand]`` has less then adds the remaining cards.
  void fillHand() {
    if (_hand.isEmpty) {
      _round = 0;
      _playedRounds = -1;
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
  /// #### Parameters
  /// - ``String [cardText]`` : the text of the card to remove from the [hand].
  void useCard(String cardText) => _hand.remove(cardText);

  /// Extract n-``[totalPlayers]`` random answer card from the ``[answerList]`` and adds to the ``[hand]`` only the i-``[playerNumber]`` card.
  /// Meaning that if there are 4 players and the user is the 3th player, extracts 4 cards and adds to the hand the 3th.
  void _drawAnswerCard() {
    int position = 0;
    for (var i = 0; i < totalPlayers; i++) {
      if (playerNumber - 1 == i) {
        position = _randomAnswerCard.nextInt(answerList.length);
      }
      _randomAnswerCard.nextInt(answerList.length);
    }
    _hand.add('$position - ${answerList[position]}');
  }

  /// Returns a list of answer cards, but without the id.
  ///
  /// E.g. 104 --> "104 - Dio" --> "Dio".
  ///
  /// #### Parameters
  /// - ``List<int> [numbers]`` : the list of id of the answer cards to draw.
  ///
  /// #### Returns
  /// - ``List<String>`` : the list of answers.
  List<String> revealAnswerCards(List<int> numbers) =>
      List.generate(numbers.length, (index) => answerList[numbers[index]]);

  /// Pick a random question card from ``[questionList]``, and saves the text in ``[question]`` and the number of empty spaces to fill in ``[_answersNeeded]``.
  /// Also increments the [round]. At the end of the method, the last time the question card is accessed it's also removed from ``[questionList]`` to avoid
  /// reusing the same card over and over.
  void drawQuestionCard() {
    _round++;
    if (((_round - 1) % totalPlayers).floor() != playerNumber) _playedRounds++;

    int position = _randomQuestionCard.nextInt(questionList.length);
    _actualQuestion = questionList[position][0];
    _answersNeeded = questionList.removeAt(position)[1];
  }

  /// Used when a round is won. Increase the ``[score]`` and clears ``[selectedCards]``.
  void won() => {_score++, _clearSelectedCard()};

  /// Used when a round is lost. Clears ``[selectedCards]``.
  void lost() => _clearSelectedCard();

  /// Clears ``[selectedCards]``.
  void _clearSelectedCard() => CasualityManager.selectedCards.clear();
}
