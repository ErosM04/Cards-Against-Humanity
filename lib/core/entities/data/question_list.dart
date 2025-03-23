import 'package:cards_against_humanity/core/entities/data/card.dart';
import 'package:cards_against_humanity/core/entities/data/card_list.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';

/// Stores a list of Cards Against Humanity's question cards.
/// Cannot be instantiated because it must be overwritten.
class QuestionList extends CardList {
  const QuestionList({required List<Question> questions})
      : super(list: questions);

  @override
  Question getCardAt(int index) {
    return super.getCardAt(index) as Question;
  }

  @override
  Question removeCardAt(int index) {
    return super.removeCardAt(index) as Question;
  }
}
