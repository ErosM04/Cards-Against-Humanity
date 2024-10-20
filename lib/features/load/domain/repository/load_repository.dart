import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/domain/entities/answer_list.dart';
import 'package:cards_against_humanity/features/load/domain/entities/question_list.dart';
import 'package:fpdart/fpdart.dart';

// Here we don't pass the QuestionListModel because it would violate encapsulation
abstract interface class LoadRepository {
  Future<Either<DataFailure, QuestionList>> getQuestions();
  Future<Either<DataFailure, AnswerList>> getAnswers();
}
