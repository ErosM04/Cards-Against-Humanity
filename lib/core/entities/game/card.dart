/// Stores the informations of a Cards Against Humanity's card.
class CAHCard {
  /// The id of the card
  final int id;

  /// The text contained in the card. Either a question or an answer.
  final String text;

  const CAHCard({required this.id, required this.text});
}
