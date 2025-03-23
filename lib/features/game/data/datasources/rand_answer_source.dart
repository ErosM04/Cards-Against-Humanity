import 'package:cards_against_humanity/features/game/data/datasources/rand_card_source.dart';
import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'dart:math';

/// Implements the methods that are used to manage the models and manipulate the data,
/// specifically for the answer cards.
class RandomAnswersSource implements RandomCardSource<Answer> {
  /// The list of cards.
  final AnswerList _answerList;

  /// The seed used by the ``[Random]`` object to generate randomic numbers.
  final int seed;

  /// The object used to generate random numbers, that correspond to the answer cards contained
  /// in ``[_answerList]``.
  final Random _randomCard;

  RandomAnswersSource({
    required this.seed,
    required AnswerList answerList,
  })  : _answerList = answerList,
        _randomCard = Random(seed);

  /// Getter that returns the next random number.
  int get _nextRandPos => _randomCard.nextInt(_answerList.length);

  @override
  Answer getCardAt(int index) {
    try {
      return _answerList.getCardAt(index);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  Answer getRandomCard() {
    try {
      return _answerList.getCardAt(_nextRandPos);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  Answer removeRandomCard() {
    try {
      return _answerList.removeCardAt(_nextRandPos);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }
}
