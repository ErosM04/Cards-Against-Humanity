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

  /// Independent PRNG streams keyed by 1-based player number for synchronized multi-player draws.
  final Map<int, Random> _playerRandoms = {};

  RandomAnswersSource({
    required this.seed,
    required AnswerListModel answerList,
  })  : _answerList = answerList,
        _randomCard = Random(seed);

  /// Getter that returns the next random number.
  int _nextPosFor(Random rng) => rng.nextInt(_answerList.length);

  /// Getter that returns the next random number.
  int get _nextRandPos => _nextPosFor(_randomCard);

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
  void skipCards(int amount, [Random? rng]) {
    if (_answerList.isEmpty) {
      throw RangeError('Cannot skip cards when answer list is empty');
    }
    final target = rng ?? _randomCard;
    for (var i = 0; i < amount; i++) {
      target.nextInt(_answerList.length);
    }
  }

  /// Draws a random answer card for a specific player ([playerNumber] between 1 and [totalPlayers])
  /// while skipping the cards belonging to other players, advancing that player's stream
  /// by [totalPlayers] steps to maintain deterministic synchronization across all devices.
  AnswerModel getRandomCardWithSkip({
    required int totalPlayers,
    required int playerNumber,
  }) {
    if (playerNumber < 1 || playerNumber > totalPlayers) {
      throw RangeError.range(playerNumber, 1, totalPlayers, 'playerNumber');
    }
    final rng = _playerRandoms.putIfAbsent(playerNumber, () => Random(seed));
    try {
      skipCards(playerNumber - 1, rng);
      final card = _answerList.getCardAt(_nextPosFor(rng)) as AnswerModel;
      skipCards(totalPlayers - playerNumber, rng);
      return card;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }
}
