import 'package:cards_against_humanity/core/entities/data/card.dart';

/// Stores a list of Cards Against Humanity's cards.
/// Cannot be instantiated because it must be overwritten.
abstract class CardList {
  final List<CardAH> _list;

  const CardList({required List<CardAH> list}) : _list = list;

  bool get isEmpty => _list.isEmpty;

  int get length => _list.length;

  CardAH getCardAt(int index) => _list[index];

  CardAH removeCardAt(int index) => _list.removeAt(index);
}
