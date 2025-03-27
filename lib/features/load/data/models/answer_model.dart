import 'package:cards_against_humanity/core/entities/data/answer.dart';

/// Defines the [Answer] object equivalent to use while inside the data layer (for stronger encapsulation).
class AnswerModel extends Answer {
  const AnswerModel({
    required super.id,
    required super.text,
  });
}
