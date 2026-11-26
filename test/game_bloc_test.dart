import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';
import 'package:cards_against_humanity/core/widgets/appbar.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_answer_source.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_question_source.dart';
import 'package:cards_against_humanity/features/game/data/repository/game_repo_impl.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_answer.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/retrive_answers.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

/// Runs unit tests for [GameBloc] hand setup, round lifecycle, and turn rotation.
void main() {
  late GameBloc bloc;
  late QuestionListModel questions;
  late AnswerListModel answers;

  setUp(() {
    questions = QuestionListModel(
      questions: List.generate(
        10,
        (i) => QuestionModel(
            id: i, text: 'Question $i', answerNeeded: i % 2 == 0 ? 1 : 2),
      ),
    );

    answers = AnswerListModel(
      answers: List.generate(
        100,
        (i) => AnswerModel(id: i, text: 'Answer $i'),
      ),
    );

    final qSource =
        RandomQuestionsSource(seed: 1234567890, questionList: questions);
    final aSource = RandomAnswersSource(seed: 1234567890, answerList: answers);
    final repo = GameRepositoryImpl(
        randQuestionsSource: qSource, randAnswersSource: aSource);

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

  test('AnswerCardsRequested emits AnswerCardsLoaded for eligible IDs and removes them',
      () async {
    final validIds = bloc.gameData.otherPlayersCardIds.take(3).toList();
    final initialCount = bloc.gameData.otherPlayersCardIds.length;

    bloc.add(AnswerCardsRequested(ids: validIds));
    await expectLater(
      bloc.stream,
      emits(predicate<GameState>((state) {
        if (state is AnswerCardsLoaded) {
          return state.answers.length == 3 &&
              state.answers.getCardAt(0).id == validIds[0] &&
              state.answers.getCardAt(1).id == validIds[1] &&
              state.answers.getCardAt(2).id == validIds[2];
        }
        return false;
      })),
    );

    expect(bloc.gameData.otherPlayersCardIds.length, equals(initialCount - 3));
  });

  test('AnswerCardsRequested rejects ineligible, already-played, and duplicate IDs',
      () async {
    // Pick an ID not present in any other player's tracked deck
    final missingId = List.generate(100, (i) => i).firstWhere(
      (id) => !bloc.gameData.otherPlayersCardIds.contains(id),
    );
    final initialIds = List<int>.from(bloc.gameData.otherPlayersCardIds);

    bloc.add(AnswerCardsRequested(ids: [missingId]));
    await expectLater(
      bloc.stream,
      emits(predicate<GameState>(
        (s) => s is LoadFailure && s.message.isNotEmpty,
      )),
    );
    expect(bloc.gameData.otherPlayersCardIds, equals(initialIds));

    // Over-duplicating an ID that appears once is rejected cleanly
    final uniqueId = initialIds.firstWhere(
      (id) => initialIds.where((e) => e == id).length == 1,
    );
    bloc.add(AnswerCardsRequested(ids: [uniqueId, uniqueId]));
    await expectLater(bloc.stream, emits(isA<LoadFailure>()));
    expect(bloc.gameData.otherPlayersCardIds, equals(initialIds));

    // Valid play removes the ID so re-using it without a redraw fails
    bloc.add(AnswerCardsRequested(ids: [uniqueId]));
    await expectLater(bloc.stream, emits(isA<AnswerCardsLoaded>()));

    bloc.add(AnswerCardsRequested(ids: [uniqueId]));
    await expectLater(bloc.stream, emits(isA<LoadFailure>()));
  });

  test('Other players eligible IDs track initial hands and non-Master refills',
      () async {
    // Player 2 of 4 starts with 3 * 10 = 30 tracked IDs from players 1, 3, 4
    expect(bloc.gameData.otherPlayersCardIds.length, equals(3 * handLength));

    // Round 1 (Master = Player 1): no refills yet
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));
    expect(bloc.gameData.otherPlayersCardIds.length, equals(3 * handLength));
    final q1Needed = bloc.cardsToClick;

    // Round 2 (Master = Player 2): only players 3 and 4 refill q1Needed cards
    bloc.add(const StartRound(isMaster: true));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));
    expect(
      bloc.gameData.otherPlayersCardIds.length,
      equals(3 * handLength + 2 * q1Needed),
    );

    // Verify independent Player 3 device draws are all eligible on Player 2
    final p3Source =
        RandomAnswersSource(seed: 1234567890, answerList: answers);
    for (var i = 0; i < handLength + q1Needed; i++) {
      final card =
          p3Source.getRandomCardWithSkip(totalPlayers: 4, playerNumber: 3);
      expect(bloc.gameData.otherPlayersCardIds, contains(card.id));
    }
  });

  test('GameData.isMasterForRound calculates round rotation accurately', () {
    // 4 players, playerNumber = 2
    // Round 1: Player 1
    // Round 2: Player 2 (Master!)
    // Round 3: Player 3
    // Round 4: Player 4
    // Round 5: Player 1
    // Round 6: Player 2 (Master!)
    expect(bloc.gameData.isMasterRound(1), isFalse);
    expect(bloc.gameData.isMasterRound(2), isTrue);
    expect(bloc.gameData.isMasterRound(3), isFalse);
    expect(bloc.gameData.isMasterRound(4), isFalse);
    expect(bloc.gameData.isMasterRound(5), isFalse);
    expect(bloc.gameData.isMasterRound(6), isTrue);
  });

  test('Initial score and round counters start at 0', () {
    expect(bloc.gameData.score, equals(0));
    expect(bloc.gameData.totalRounds, equals(0));
    expect(bloc.gameData.playerRounds, equals(0));
  });

  test('RoundWon increments score and playerRounds; RoundLost only playerRounds',
      () async {
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));

    bloc.add(const RoundWon());
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));

    expect(bloc.gameData.score, equals(1));
    expect(bloc.gameData.playerRounds, equals(1));
    expect(bloc.selectedCards, isEmpty);

    bloc.add(const RoundLost());
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));

    expect(bloc.gameData.score, equals(1));
    expect(bloc.gameData.playerRounds, equals(2));
    expect(bloc.selectedCards, isEmpty);
  });

  test('Winning right before a Master turn keeps playerRounds >= score',
      () async {
    // Round 1 as Player: win before transitioning to Master
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));
    expect(bloc.gameData.totalRounds, equals(1));
    expect(bloc.gameData.playerRounds, equals(0));
    expect(bloc.gameData.score, equals(0));

    bloc.add(const RoundWon());
    bloc.add(const StartRound(isMaster: true));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));

    // On Round 2 (Master), score must remain 1/1 and totalRounds == 2
    expect(bloc.gameData.totalRounds, equals(2));
    expect(bloc.gameData.score, equals(1));
    expect(bloc.gameData.playerRounds, equals(1));
    expect(bloc.gameData.playerRounds >= bloc.gameData.score, isTrue);

    // Master finishes Round 2 and starts Round 3 (no RoundWon/RoundLost)
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));
    expect(bloc.gameData.totalRounds, equals(3));
    expect(bloc.gameData.score, equals(1));
    expect(bloc.gameData.playerRounds, equals(1));

    // Lose Round 3 then start Round 4
    bloc.add(const RoundLost());
    bloc.add(const StartRound(isMaster: false));
    await expectLater(bloc.stream, emits(isA<RoundReady>()));
    expect(bloc.gameData.totalRounds, equals(4));
    expect(bloc.gameData.score, equals(1));
    expect(bloc.gameData.playerRounds, equals(2));
  });

  testWidgets('CustomAppBar displays score/maxPoints on win-before-master flow',
      (tester) async {
    Future<void> dispatchRound(List<GameEvent> events) => tester.runAsync(() async {
          for (final event in events) {
            bloc.add(event);
          }
          await expectLater(bloc.stream, emits(isA<RoundReady>()));
        });

    Future<void> pumpAppBar() => tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              appBar: CustomAppBar(
                score: bloc.gameData.score,
                maxPoints: bloc.gameData.playerRounds,
              ),
            ),
          ),
        );

    // Round 1 (Player)
    await dispatchRound(const [StartRound(isMaster: false)]);
    await pumpAppBar();
    expect(find.text('0/0'), findsOneWidget);

    // Win Round 1 -> Round 2 (Master)
    await dispatchRound(const [RoundWon(), StartRound(isMaster: true)]);
    await pumpAppBar();
    expect(find.text('1/1'), findsOneWidget);

    // Lose Round 3 -> Round 4 (Player)
    await dispatchRound(const [StartRound(isMaster: false)]);
    await dispatchRound(const [RoundLost(), StartRound(isMaster: false)]);
    await pumpAppBar();
    expect(find.text('1/2'), findsOneWidget);

    // Default CustomAppBar (e.g. StartPage) hides score counter
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(appBar: CustomAppBar())),
    );
    expect(find.text('Cards Against'), findsOneWidget);
    expect(find.text('Humanity'), findsOneWidget);
    expect(find.textContaining('/'), findsNothing);
  });
}
