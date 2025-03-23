import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:fpdart/fpdart.dart';

/// Defines the methods that will be used by the `usecases` and implemented in the data layer.
abstract interface class GameRepository {
  /// Retrives a question card from the datasource and removes it.
  Either<DataRangeFailure, Question> drawQuestionCard();

  /// Retrives [amount] random answer cards from the datasource and removes them.
  Either<DataRangeFailure, AnswerList> drawAnswerCards(int amount);

  /// Handles the call to the datasource (list of answers) to retrive the list of answers based on the given ids.
  Either<DataRangeFailure, AnswerList> retriveAnswers(List<int> ids);
}
