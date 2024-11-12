import 'package:cards_against_humanity/core/entities/game/card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'card_event.dart';
part 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  /// The amount of answer cards to click to complete the question (1 or 2).
  int cardsToClick;

  /// The answer cards clicked till now.
  int clickedCards = 0;

  /// The variable used to save the first card clicked, in case 2 cards are required ([cardsToClick] = 2).
  late CardAH _firstCard;

  CardBloc(this.cardsToClick) : super(NoCardClicked()) {
    clickedCard();
  }

  void clickedCard() {
    return on<CardClicked>((event, emit) {
      clickedCards++;
      _firstCard = event.card;

      if (clickedCards == cardsToClick) {
        if (cardsToClick == 1) {
          // Only one answer was required
          emit(OneCardCliked(card: event.card));
        } else {
          // Two answers were required so the previous card, saved in the local variable, is used.
          emit(TwoCardCliked(card1: _firstCard, card2: event.card));
        }
      }
    });
  }
}
