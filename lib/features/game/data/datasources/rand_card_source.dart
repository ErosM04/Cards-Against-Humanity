/// Defines the methods that are used to manage the models and manipulate the data.
abstract interface class RandomCardSource<Card> {
  /// Returns the next random card.
  /// Throws [RangeError] if there are no more cards in the list.
  Card getRandomCard();

  /// Returns the next random card and deletes it from the list.
  /// Throws [RangeError] if there are no more cards in the list.
  Card removeRandomCard();
}
