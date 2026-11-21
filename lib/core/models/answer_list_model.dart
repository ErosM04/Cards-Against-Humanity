import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';

/// The model is used for data mapping and parsing.
class AnswerListModel extends AnswerList {
  const AnswerListModel({required super.answers});

  /// Takes a [list] of answer strings.
  factory AnswerListModel.fromStrings({required List<String> list}) {
    List<AnswerModel> finalList = [];

    for (int i = 0; i < list.length; i++) {
      finalList.add(
        AnswerModel(
          id: i,
          text: list[i],
        ),
      );
    }

    return AnswerListModel(answers: finalList);
  }
}
