import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/features/game/data/models/question_model.dart';

/// The model is only here for the data layer, so it won't be used outside it.
class QuestionListModel extends QuestionList {
  const QuestionListModel({required super.questions});

  /// Takes a [list] which where a `List` contains all the questions, whith each question being a `List`
  /// containing two elements, the qeuestion string and the amount of answers needed:
  ///
  /// E.g.
  /// ```
  /// [
  ///   ['________ sarebbe terribilmente incompleto senza ________ .', '2'],
  ///   ['... e l’avrei scampata, se non fosse stato per ________ .', '1'],
  ///   ...
  /// ]
  /// ```
  ///
  /// Then for each sub-list creates a [QuestionModel] to populate a list used to create the [QuestionListModel] object.
  factory QuestionListModel.fromList({required List<List<String>> list}) {
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
  static int _parse(value) {
    if (value is int) {
      return value;
    } else {
      return int.tryParse(value.toString()) ?? 1;
    }
  }
}
