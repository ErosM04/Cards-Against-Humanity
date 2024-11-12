part of 'card_bloc.dart';

@immutable
sealed class CardState {}

final class NoCardClicked extends CardState {}

final class OneCardCliked extends CardState {
  final CardAH card;

  OneCardCliked({required this.card});
}

final class TwoCardCliked extends CardState {
  final CardAH card1;
  final CardAH card2;

  TwoCardCliked({required this.card1, required this.card2});
}
