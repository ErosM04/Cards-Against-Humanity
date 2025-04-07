import 'package:cards_against_humanity/core/entities/data/card_list.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';

/// Stores a list of Cards Against Humanity's question cards.
class QuestionList extends CardList<Question> {
  const QuestionList({required List<Question> questions})
      : super(list: questions);
}
