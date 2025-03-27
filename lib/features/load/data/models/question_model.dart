import 'package:cards_against_humanity/core/entities/data/question.dart';

/// Defines the [Question] object equivalent to use while inside the data layer (for stronger encapsulation).
class QuestionModel extends Question {
  const QuestionModel({
    required super.id,
    required super.text,
    required super.answerNeeded,
  });
}
