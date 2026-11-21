import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:fpdart/fpdart.dart';

/// Defines the methods that will be used by the `usecases` and implemented in the data layer.
// Here we don't pass the QuestionListModel because it would violate encapsulation
abstract interface class LoadRepository {
  /// Handles the call to the `data source` to retrive the list of questions.
  Future<Either<DataFailure, QuestionList>> getQuestions();

  /// Handles the call to the `data source` to retrive the list of answers.
  Future<Either<DataFailure, AnswerList>> getAnswers();
}
