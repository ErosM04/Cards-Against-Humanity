/// Stores the informations of a Cards Against Humanity's card.
/// Cannot be instantiated because it must be overwritten.
abstract class CardAH {
  /// The id of the card
  final int id;

  /// The text contained in the card. Either a question or an answer.
  final String text;

  const CardAH({required this.id, required this.text});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardAH &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text;

  @override
  int get hashCode => id.hashCode ^ text.hashCode;
}
