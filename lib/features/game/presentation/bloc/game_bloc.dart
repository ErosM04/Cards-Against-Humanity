import 'package:cards_against_humanity/core/entities/data/card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  /// The amount of answer cards to click to complete the question (1 or 2).
  int cardsToClick;

  /// The answer cards clicked till now.
  int clickedCards = 0;

  /// The variable used to save the first card clicked, in case 2 cards are required ([cardsToClick] = 2).
  late CardAH _firstCard;

  GameBloc(this.cardsToClick) : super(NoCardClicked()) {
    clickedCard();
  }

  void clickedCard() {
    return on<GameClicked>((event, emit) {
      clickedCards++;
      _firstCard = event.card;

      if (clickedCards == cardsToClick) {
        if (cardsToClick == 1) {
          // Only one answer was required
          emit(OneCardCliked(card: event.card));
        } else {
          // Two answers were required so the previous card, saved in the local variable, is used.
          emit(TwoCardsCliked(card1: _firstCard, card2: event.card));
        }
      }
    });
  }
}
