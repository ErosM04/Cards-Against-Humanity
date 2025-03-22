import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/card_list.dart';

/// Stores a list of Cards Against Humanity's answer cards.
/// Cannot be instantiated because it must be overwritten.
class AnswerList extends CardList {
  const AnswerList({required List<Answer> answers}) : super(list: answers);
}
