import 'package:cards_against_humanity/features/load/domain/entities/data_list.dart';
import 'package:cards_against_humanity/features/load/domain/entities/question.dart';

class QuestionList implements DataList {
  @override
  final List<Question> list;

  const QuestionList({required this.list});

  @override
  bool get isEmpty => list.isEmpty;

  @override
  Question getQuestionAt(int index) => list[index];

  @override
  Question removeQuestionAt(int index) => list.removeAt(index);
}
