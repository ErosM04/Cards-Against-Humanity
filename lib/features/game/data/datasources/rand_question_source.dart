import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_card_source.dart';
import 'dart:math';

/// Implements the methods that are used to manage the models and manipulate the data,
/// specifically for the question cards.
class RandomQuestionsSource implements RandomCardSource<QuestionModel> {
  /// The list of question cards.
  final QuestionListModel _questionList;

  /// The seed used by the ``[Random]`` object to generate randomic numbers.
  final int seed;

  /// The object used to generate random numbers, that correspond to the question cards contained
  /// in ``[_questionList]``.
  final Random _randomCard;

  RandomQuestionsSource({
    required this.seed,
    required QuestionListModel questionList,
  })  : _questionList = questionList,
        _randomCard = Random(seed + 1);

  /// Getter that returns the next random number.
  int get _nextRandPos => _randomCard.nextInt(_questionList.length);

  @override
  QuestionModel getCardAt(int index) {
    try {
      return _questionList.getCardAt(index) as QuestionModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  QuestionModel getRandomCard() {
    try {
      return _questionList.getCardAt(_nextRandPos) as QuestionModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  QuestionModel removeRandomCard() {
    try {
      return _questionList.removeCardAt(_nextRandPos) as QuestionModel;
    } catch (e) {
      throw RangeError(e.toString());
    }
  }
}
