import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/card.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_answer.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/retrive_answers.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'game_event.dart';
part 'game_state.dart';

/// Manages match state, card drawing, hand selections, and player score.
class GameBloc extends Bloc<GameEvent, GameState> {
  /// Usecase used to retrive a list of answers that correspond to a given id list.
  final RetriveAnswers _retriveAnswers;

  /// Usecase that provides a question card.
  final DrawNextQuestion _drawNextQuestion;

  /// Usecase that provides an answer card.
  final DrawNextAnswer _drawNextAnswer;

  late GameData _gameData;

  /// Current match state and player hand data.
  GameData get gameData => _gameData;

  /// The question card of the current round.
  Question? _currentQuestion;

  /// The question card of the current round.
  Question? get currentQuestion => _currentQuestion;

  /// List of answers selected by the player in the current round.
  final List<Answer> _selectedCards = [];

  /// List of answers selected by the player in the current round.
  List<Answer> get selectedCards => List.unmodifiable(_selectedCards);

  /// The amount of answer cards to click to complete the question (1 or 2).
  int _cardsToClick = 1;

  /// The amount of answer cards to click to complete the question (1 or 2).
  int get cardsToClick => _cardsToClick;

  /// The answer cards clicked till now.
  int _clickedCards = 0;

  /// The answer cards clicked till now.
  int get clickedCards => _clickedCards;

  /// The variable used to save the first card clicked, in case 2 cards are required ([_cardsToClick] = 2).
  CardAH? _firstCard;

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

    GameData.resetState(
      playerNumber: playerNumber,
      totalPlayers: totalPlayers,
      hand: hand,
    );
    _gameData = GameData(
      playerNumber: playerNumber,
      totalPlayers: totalPlayers,
      hand: hand,
    );

    /// Events definition
    on<StartRound>(_roundStart);
    on<AnswerCardsRequested>(_answerCardRequested);
    on<CardClicked>(_clickedCard);
    on<RoundWon>(_roundWon);
    on<RoundLost>(_roundLost);
  }

  /// Draws missing cards to complete hand until it contains [handLength] cards.
  void _roundStart(StartRound event, Emitter<GameState> emit) {
    _selectedCards.clear();
    _clickedCards = 0;
    _firstCard = null;

    _gameData.newRound();

    final questionRes = _drawNextQuestion();
    questionRes.fold(
      (fail) => emit(LoadFailure()),
      (question) {
        _currentQuestion = question;
        _cardsToClick = question.answerNeeded;
      },
    );

    // Refill hand up to handLength (10)
    final missingCards = handLength - _gameData.handList.length;
    for (var i = 0; i < missingCards; i++) {
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

  void _answerCardRequested(
      AnswerCardsRequested event, Emitter<GameState> emit) {
    final res = _retriveAnswers(event.ids);
    res.fold(
      (fail) => emit(LoadFailure()),
      (answers) => emit(AnswerCardsLoaded(answers: answers)),
    );
  }

  /// Toggles card selection and finishes the turn once [cardsToClick] cards are chosen.
  void _clickedCard(CardClicked event, Emitter<GameState> emit) {
    final answer = event.card is Answer
        ? event.card as Answer
        : Answer(id: event.card.id, text: event.card.text);

    // If card was already selected, deselect it
    if (_selectedCards.contains(answer)) {
      _selectedCards.remove(answer);
      _clickedCards = _selectedCards.length;
      _firstCard = _selectedCards.isNotEmpty ? _selectedCards.first : null;
      emit(RoundReady());
      return;
    }

    _selectedCards.add(answer);
    _clickedCards = _selectedCards.length;

    if (_clickedCards == 1) {
      _firstCard = answer;
    }

    if (_clickedCards == _cardsToClick) {
      // Remove used cards from hand
      for (final card in _selectedCards) {
        _gameData.removeAnswerCard(card);
      }
      if (_cardsToClick == 1) {
        emit(FirstCardCliked(card: answer));
      } else {
        emit(SecondCardCliked(card1: _firstCard!, card2: answer));
      }
    } else {
      emit(RoundReady());
    }
  }

  // Records a won round and clears the selected cards.
  void _roundWon(RoundWon event, Emitter<GameState> emit) {
    _gameData.recordPlayerRound(won: true);
    _selectedCards.clear();
  }

  // Records a lost round without increasing the score and clears the selected cards.
  void _roundLost(RoundLost event, Emitter<GameState> emit) {
    _gameData.recordPlayerRound(won: false);
    _selectedCards.clear();
  }
}
