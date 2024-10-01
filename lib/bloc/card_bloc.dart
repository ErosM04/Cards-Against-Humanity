import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'card_event.dart';
part 'card_state.dart';

class CardBloc extends Bloc<CardEvent, CardState> {
  CardBloc() : super(NoCardClicked()) {
    clickedCard();
  }

  void clickedCard() {
    return on<CardClicked>((event, emit) {
      // event.clickedCards;
    });
  }
}
