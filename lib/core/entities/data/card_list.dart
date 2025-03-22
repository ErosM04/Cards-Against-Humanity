import 'package:cards_against_humanity/core/entities/data/card.dart';

/// Stores a list of Cards Against Humanity's cards.
/// Cannot be instantiated because it must be overwritten.
abstract class CardList {
  final List<CardAH> list;

  const CardList({required this.list});

  bool get isEmpty => list.isEmpty;

  int get length => list.length;

  CardAH getCardAt(int index) => list[index];

  CardAH removeCardAt(int index) => list.removeAt(index);
}
