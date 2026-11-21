import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_answer_source.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_question_source.dart';
import 'package:cards_against_humanity/features/game/data/repository/game_repo_impl.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_answer.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/retrive_answers.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GameBloc bloc;
  late QuestionListModel questions;
  late AnswerListModel answers;

  setUp(() {
    questions = QuestionListModel(
      questions: List.generate(
        10,
        (i) => QuestionModel(id: i, text: 'Question $i', answerNeeded: i % 2 == 0 ? 1 : 2),
      ),
    );

    answers = AnswerListModel(
      answers: List.generate(
        100,
        (i) => AnswerModel(id: i, text: 'Answer $i'),
      ),
    );

    final qSource = RandomQuestionsSource(seed: 1234567890, questionList: questions);
    final aSource = RandomAnswersSource(seed: 1234567890, answerList: answers);
    final repo = GameRepositoryImpl(randQuestionsSource: qSource, randAnswersSource: aSource);

    bloc = GameBloc(
      retriveAnswers: RetriveAnswers(gameRepository: repo),
      drawNextQuestion: DrawNextQuestion(gameRepository: repo),
      drawNextAnswer: DrawNextAnswer(gameRepository: repo),
      playerNumber: 2,
      totalPlayers: 4,
    );
  });

  tearDown(() {
    bloc.close();
  });

  test('GameBloc initializes hand with 10 cards and starts at RoundStart', () {
    expect(bloc.state, isA<RoundStart>());
    expect(bloc.gameData.handList.length, equals(handLength));
  });

  test('StartRound draws question and emits RoundReady', () async {
    bloc.add(const StartRound(isMaster: false));
    await expectLater(
      bloc.stream,
      emits(isA<RoundReady>()),
    );

    expect(bloc.currentQuestion, isNotNull);
    expect(bloc.gameData.handList.length, equals(handLength));
    expect(bloc.gameData.totalRounds, equals(1));
    expect(bloc.gameData.playerRounds, equals(0));
  });

  test('CardClicked emits FirstCardCliked when 1 answer needed', () async {
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));

    // Make sure 1 card needed
    final cardToClick = bloc.gameData.handList.getCardAt(0);

    if (bloc.cardsToClick == 1) {
      bloc.add(CardClicked(cardToClick));
      await expectLater(
        bloc.stream,
        emits(isA<FirstCardCliked>()),
      );
      expect(bloc.selectedCards.length, equals(1));
      expect(bloc.selectedCards.first.id, equals(cardToClick.id));
      expect(bloc.gameData.handList.length, equals(9));
    }
  });

  test('AnswerCardsRequested emits AnswerCardsLoaded with correct cards', () async {
    bloc.add(const AnswerCardsRequested(ids: [5, 10, 15]));
    await expectLater(
      bloc.stream,
      emits(predicate<GameState>((state) {
        if (state is AnswerCardsLoaded) {
          return state.answers.length == 3 &&
              state.answers.getCardAt(0).id == 5 &&
              state.answers.getCardAt(1).id == 10 &&
              state.answers.getCardAt(2).id == 15;
        }
        return false;
      })),
    );
  });

  test('GameData.isMasterForRound calculates round rotation accurately', () {
    // 4 players, playerNumber = 2
    // Round 1: Player 1
    // Round 2: Player 2 (Master!)
    // Round 3: Player 3
    // Round 4: Player 4
    // Round 5: Player 1
    // Round 6: Player 2 (Master!)
    expect(bloc.gameData.isMasterForRound(1), isFalse);
    expect(bloc.gameData.isMasterForRound(2), isTrue);
    expect(bloc.gameData.isMasterForRound(3), isFalse);
    expect(bloc.gameData.isMasterForRound(4), isFalse);
    expect(bloc.gameData.isMasterForRound(5), isFalse);
    expect(bloc.gameData.isMasterForRound(6), isTrue);
  });
}
