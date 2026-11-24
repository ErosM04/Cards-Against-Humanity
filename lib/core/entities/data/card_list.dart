/// Stores a list of Cards Against Humanity's cards.
/// Cannot be instantiated because it must be overwritten.
abstract class CardList<Card> {
  final List<Card> _list;

  const CardList({required List<Card> list}) : _list = list;

  /// Whether this list contains no cards.
  bool get isEmpty => _list.isEmpty;

  /// Number of cards currently stored in this list.
  int get length => _list.length;

  /// Returns the card at [index].
  Card getCardAt(int index) => _list[index];

  /// Removes and returns the card at [index].
  Card removeCardAt(int index) => _list.removeAt(index);

  /// Adds a new card in tail.
  void addCard(Card card) => _list.add(card);

  /// Removes a card from the list.
  bool removeCard(Card card) => _list.remove(card);
}
