part of 'card_bloc.dart';

@immutable
sealed class CardState {}

final class NoCardClicked extends CardState {}

final class OneCardCliked extends CardState {
  final String cardText;
  final int cardId;

  OneCardCliked({required this.cardText, required this.cardId});
}

final class TwoCardCliked extends CardState {
  final String firstCardText;
  final int firstCardId;
  final String secondCardText;
  final int secondCardId;

  TwoCardCliked({
    required this.firstCardText,
    required this.secondCardText,
    required this.firstCardId,
    required this.secondCardId,
  });
}
