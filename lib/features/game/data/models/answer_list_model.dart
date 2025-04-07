import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/features/game/data/models/answer_model.dart';

/// The model is only here for the data layer, so it won't be used outside it.
class AnswerListModel extends AnswerList {
  const AnswerListModel({required super.answers});

  /// Takes a [list] that contains all the answers, whith each answer being a [List]
  /// containing the answer [String]:
  ///
  /// E.g.:
  /// ```
  /// [
  ///   ['Far precipitare il lampadario sui tuoi nemici e risalire con la corda'],
  ///   ['Schiaffeggiare una vecchietta razzista'],
  ///   ...
  /// ]
  /// ```
  ///
  /// For each sub-list creates a [AnswerModel] to populate a [List] used to create the [AnswerListModel] object.
  factory AnswerListModel.fromStrings({required List<String> list}) {
    List<AnswerModel> finalList = [];

    for (int i = 0; i < list.length; i++) {
      finalList.add(
        AnswerModel(
          id: i,
          text: list[i][0].toString(),
        ),
      );
    }

    return AnswerListModel(answers: finalList);
  }
}
