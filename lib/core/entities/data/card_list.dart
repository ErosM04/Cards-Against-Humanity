/// Stores a list of Cards Against Humanity's cards.
/// Cannot be instantiated because it must be overwritten.
abstract class CardList<Card> {
  final List<Card> _list;

  const CardList({required List<Card> list}) : _list = list;

  bool get isEmpty => _list.isEmpty;

  int get length => _list.length;

  Card getCardAt(int index) => _list[index];

  Card removeCardAt(int index) => _list.removeAt(index);

  /// Adds a new card in tail.
  void addCard(Card card) => _list.add(card);

  /// Removes a card from the list.
  bool removeCard(Card card) => _list.remove(card);
}
