part of 'card_bloc.dart';

@immutable
sealed class CardEvent {}

final class CardClicked extends CardEvent {
  final CardAH card;

  CardClicked(this.card);
}
