part of 'card_bloc.dart';

@immutable
sealed class CardEvent {}

final class CardClicked extends CardEvent {
  final int clickedCards;
  final int totalCardsToClick;

  CardClicked({required this.clickedCards, required this.totalCardsToClick});
}

// invoke with: context.read<CardBloc>().add(CardClicked());
