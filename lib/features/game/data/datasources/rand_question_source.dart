import 'package:cards_against_humanity/features/game/data/datasources/rand_card_source.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'dart:math';

/// Implements the methods that are used to manage the models and manipulate the data,
/// specifically for the question cards.
class RandomQuestionsSource implements RandomCardSource<Question> {
  /// The list of question cards.
  final QuestionList _answerList;

  /// The seed used by the ``[Random]`` object to generate randomic numbers.
  final int seed;

  /// The object used to generate random numbers, that correspond to the question cards contained
  /// in ``[_answerList]``.
  final Random _randomCard;

  RandomQuestionsSource({
    required this.seed,
    required QuestionList questionList,
  })  : _answerList = questionList,
        _randomCard = Random(seed);

  /// Getter that returns the next random number.
  int get _nextRandPos => _randomCard.nextInt(_answerList.length);

  @override
  Question getCardAt(int index) {
    try {
      return _answerList.getCardAt(index);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  Question getRandomCard() {
    try {
      return _answerList.getCardAt(_nextRandPos);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }

  @override
  Question removeRandomCard() {
    try {
      return _answerList.removeCardAt(_nextRandPos);
    } catch (e) {
      throw RangeError(e.toString());
    }
  }
}
