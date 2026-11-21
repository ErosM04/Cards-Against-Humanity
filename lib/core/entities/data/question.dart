import 'package:cards_against_humanity/core/entities/data/card.dart';

/// Stores the informations of a Cards Against Humanity's question card.
class Question extends CardAH {
  /// The amount of answers needed to complete the question card (1 or 2)
  final int answerNeeded;

  const Question({
    required super.id,
    required super.text,
    required this.answerNeeded,
  });
}
