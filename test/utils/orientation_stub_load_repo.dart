import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class OrientationStubLoadRepo implements LoadRepository {
  @override
  Future<Either<DataFailure, QuestionList>> getQuestions() async => right(
        QuestionListModel(
          questions: [QuestionModel(id: 1, text: 'Q', answerNeeded: 1)],
        ),
      );

  @override
  Future<Either<DataFailure, AnswerList>> getAnswers() async => right(
        AnswerListModel(
          answers: [AnswerModel(id: 1, text: 'A')],
        ),
      );
}
