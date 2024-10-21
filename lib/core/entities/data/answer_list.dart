import 'package:cards_against_humanity/core/entities/data/data_list.dart';

class AnswerList implements DataList {
  @override
  final List<String> list;

  const AnswerList({required this.list});

  @override
  bool get isEmpty => list.isEmpty;

  @override
  int get length => list.length;

  @override
  String getQuestionAt(int index) => list[index];

  @override
  String removeQuestionAt(int index) => list.removeAt(index);
}
