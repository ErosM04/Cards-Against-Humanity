import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_answer_source.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_question_source.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implements the methods that will be used by the `usecases`.
/// This class act as a conduit between the data layer (datasource) and the domain layer (usecases).
class GameRepositoryImpl implements GameRepository {
  /// The data source that manage the list of randomically picked questions.
  final RandomQuestionsSource randQuestionsSource;

  /// The data source that manage the list of randomically picked answers.
  final RandomAnswersSource randAnswersSource;

  const GameRepositoryImpl({
    required this.randQuestionsSource,
    required this.randAnswersSource,
  });

  @override
  Either<DataRangeFailure, Question> drawQuestionCard() {
    try {
      return right(randQuestionsSource.removeRandomCard());
    } on RangeError {
      return left(DataRangeFailure(dataType: RandomQuestionsSource));
    }
  }

  @override
  Either<DataRangeFailure, AnswerList> drawAnswerCards([int amount = 0]) {
    try {
      return right(AnswerList(
          answers: List<Answer>.generate(
        amount,
        (index) => randAnswersSource.getRandomCard(),
      )));
    } on RangeError {
      return left(DataRangeFailure(dataType: RandomAnswersSource));
    }
  }

  @override
  Either<DataRangeFailure, AnswerList> retriveAnswers(List<int> ids) {
    try {
      return right(AnswerList(
          answers: List<Answer>.generate(
        ids.length,
        (index) => randAnswersSource.getCardAt(index),
      )));
    } on RangeError {
      return left(DataRangeFailure(dataType: RandomAnswersSource));
    }
  }
}
