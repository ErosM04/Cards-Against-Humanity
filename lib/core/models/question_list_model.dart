import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';

/// The model is used for data mapping and parsing.
class QuestionListModel extends QuestionList {
  const QuestionListModel({required super.questions});

  /// Takes a [list] where each element is a list containing the question text and the amount of answers needed.
  factory QuestionListModel.fromList({required List<List> list}) {
    List<QuestionModel> finalList = [];

    for (int i = 0; i < list.length; i++) {
      var subList = list[i];
      finalList.add(
        QuestionModel(
          id: i,
          text: subList[0].toString(),
          answerNeeded: _parse(subList[1]),
        ),
      );
    }

    return QuestionListModel(questions: finalList);
  }

  /// Parses a [value] to an int, otherwise returns `1`.
  static int _parse(dynamic value) {
    if (value is int) {
      return value;
    } else {
      return int.tryParse(value.toString()) ?? 1;
    }
  }
}
