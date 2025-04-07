import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/card_list.dart';

/// Stores a list of Cards Against Humanity's answer cards.
class AnswerList extends CardList<Answer> {
  const AnswerList({required List<Answer> answers}) : super(list: answers);
}
