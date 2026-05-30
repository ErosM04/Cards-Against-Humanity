import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/card.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_answer.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/retrive_answers.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_event.dart';
part 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameState> {
  /// Usecase used to retrive a list of answers that correspond to a given id list.
  final RetriveAnswers _retriveAnswers;

  /// Usecase that provides a question card.
  final DrawNextQuestion _drawNextQuestion;

  /// Usecase that provides an answer card.
  final DrawNextAnswer _drawNextAnswer;

  late GameData _gameData;

  /// The amount of answer cards to click to complete the question (1 or 2).
  int _cardsToClick = 1;

  /// The answer cards clicked till now.
  int _clickedCards = 0;

  /// The variable used to save the first card clicked, in case 2 cards are required ([_cardsToClick] = 2).
  CardAH? _firstCard;

  /// Il BlocProvider per inizializzare questo bloc va messo nel route che dalla start page ti porta
  /// alle game pages. In quel route mi faccio passare gli interi, mentre per gli usecases
  /// usa serviceLocator.nomeUseCase
  /// Draws the starting hand.
  GameBloc({
    required RetriveAnswers retriveAnswers,
    required DrawNextQuestion drawNextQuestion,
    required DrawNextAnswer drawNextAnswer,
    required int playerNumber,
    required int totalPlayers,
  })  : _retriveAnswers = retriveAnswers,
        _drawNextQuestion = drawNextQuestion,
        _drawNextAnswer = drawNextAnswer,
        super(RoundStart()) {
    /// Creates the starting hand
    AnswerList hand = AnswerList(answers: []);
    for (var i = 0; i < handLength; i++) {
      final res = _drawNextAnswer(DrawAnswerParams(
          totalPlayers: totalPlayers, playerNumber: playerNumber));
      res.fold((fail) => throw Exception(fail.message),
          (answer) => hand.addCard(answer));
    }

    _gameData = GameData(
      playerNumber: playerNumber,
      totalPlayers: totalPlayers,
      hand: hand,
    );

    /// events definition
    on<StartRound>(_roundStart);
    on<AnswerCardsRequested>(_answerCardRequested);
    on<CardClicked>(clickedCard);
  }

  /// Draws missing cards to complete hand until it contains [handLength] cards.
  void _roundStart(StartRound event, Emitter<GameState> emit) {
    if (event.isMaster) {
      _gameData.newRoundAsMaster();
    } else {
      _gameData.newRoundAsPlayer();
    }

    for (var i = 0; i < handLength; i++) {
      final res = _drawNextAnswer(DrawAnswerParams(
        totalPlayers: _gameData.totalPlayers,
        playerNumber: _gameData.playerNumber,
      ));
      res.fold(
        (fail) => throw Exception(fail.message),
        (answer) => _gameData.addAnswerCard(answer),
      );
    }

    emit(RoundReady());
  }

  void _answerCardRequested(event, emit) {}

  void clickedCard(event, emit) {
    _clickedCards++;
    _firstCard = event.card;

    if (_clickedCards == _cardsToClick) {
      if (_cardsToClick == 1) {
        // Only one answer was required
        emit(FirstCardCliked(card: event.card));
      } else {
        // Two answers were required so the previous card, saved in the local variable, is used.
        emit(SecondCardCliked(card1: _firstCard, card2: event.card));
      }
    }
  }
}
