import 'package:cards_against_humanity/features/game/data/datasources/rand_card_source.dart';
import 'package:cards_against_humanity/features/game/data/models/answer_list_model.dart';
import 'package:cards_against_humanity/features/game/data/models/answer_model.dart';
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
}
