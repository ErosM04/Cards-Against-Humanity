import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_card_source.dart';
import 'dart:math';

/// Implements the methods that are used to manage the models and manipulate the data,
/// specifically for the answer cards.
class RandomAnswersSource implements RandomCardSource<AnswerModel> {
  /// The list of cards.
  final AnswerListModel _answerList;

  /// The seed used by the ``[Random]`` object to generate randomic numbers.
  final int seed;

  /// The object used to generate random numbers, that correspond to the answer cards contained
  /// in ``[_answerList]``.
  final Random _randomCard;

  RandomAnswersSource({
    required this.seed,
    required AnswerListModel answerList,
  })  : _answerList = answerList,
        _randomCard = Random(seed);

  /// Getter that returns the next random number.
  int get _nextRandPos => _randomCard.nextInt(_answerList.length);

  @override
  AnswerModel getCardAt(int index) {
    try {
      return _answerList.getCardAt(index) as AnswerModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  AnswerModel getRandomCard() {
    try {
      return _answerList.getCardAt(_nextRandPos) as AnswerModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  AnswerModel removeRandomCard() {
    try {
      return _answerList.removeCardAt(_nextRandPos) as AnswerModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  /// Skips [amount] cards in the random sequence to keep PRNG streams synchronized.
  void skipCards(int amount) {
    if (_answerList.isEmpty) {
      throw RangeError('Cannot skip cards when answer list is empty');
    }
    for (var i = 0; i < amount; i++) {
      _randomCard.nextInt(_answerList.length);
    }
  }

  /// Draws a random answer card for a specific player ([playerNumber] between 1 and [totalPlayers])
  /// while skipping the cards belonging to other players, advancing the random generator
  /// by [totalPlayers] steps to maintain deterministic synchronization across all devices.
  AnswerModel getRandomCardWithSkip({
    required int totalPlayers,
    required int playerNumber,
  }) {
    if (playerNumber < 1 || playerNumber > totalPlayers) {
      throw RangeError.range(playerNumber, 1, totalPlayers, 'playerNumber');
    }
    skipCards(playerNumber - 1);
    final card = getRandomCard();
    skipCards(totalPlayers - playerNumber);
    return card;
  }
}
