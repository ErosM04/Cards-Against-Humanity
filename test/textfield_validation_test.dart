import '../test/utils/fake_update_repo.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
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
import 'package:cards_against_humanity/features/game/presentation/pages/master_page.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/features/load/presentation/page/start_page.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/clear_cached_updates.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:cards_against_humanity/core/widgets/card.dart';
import 'package:cards_against_humanity/core/widgets/textfield.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_ui/material_ui.dart';

class _StubLoadRepo implements LoadRepository {
  final QuestionListModel questions;
  final AnswerListModel answers;

  _StubLoadRepo(this.questions, this.answers);

  @override
  Future<Either<DataFailure, QuestionList>> getQuestions() async =>
      right(questions);

  @override
  Future<Either<DataFailure, AnswerList>> getAnswers() async => right(answers);
}

/// Runs widget tests for [StartPage] and [MasterGamePage] text-field validators.
void main() {
  QuestionListModel makeQuestions() => QuestionListModel(
        questions: [
          const QuestionModel(
            id: 0,
            text: 'Domanda ________.',
            answerNeeded: 1,
          ),
        ],
      );
  AnswerListModel makeAnswers() => AnswerListModel(
        answers: List.generate(
          40,
          (i) => AnswerModel(id: i, text: 'Risposta $i'),
        ),
      );

  testWidgets('StartPage displays validator errors below fields without clearing text',
      (tester) async {
    final loadRepo = _StubLoadRepo(makeQuestions(), makeAnswers());
    final loadBloc = LoadBloc(
      loadQuestions: LoadQuestions(loadRepository: loadRepo),
      loadAnswers: LoadAnswers(loadRepository: loadRepo),
    );
    final updateRepo = FakeUpdateRepository();
    final updateBloc = UpdateBloc(
      checkForUpdate: CheckForUpdate(updateRepository: updateRepo),
      downloadApk: DownloadApk(updateRepository: updateRepo),
      installApk: InstallApk(updateRepository: updateRepo),
      clearCachedUpdates: ClearCachedUpdates(updateRepository: updateRepo),
      managePermission: ManageUpdatePermission(updateRepository: updateRepo),
      permissionPromptDelay: Duration.zero,
    );
    addTearDown(() async {
      await loadBloc.close();
      await updateBloc.close();
    });

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: loadBloc),
          BlocProvider.value(value: updateBloc),
        ],
        child: const MaterialApp(home: StartPage()),
      ),
    );

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'abc');
    await tester.enterText(fields.at(1), '25');
    await tester.enterText(fields.at(2), '2');

    await tester.ensureVisible(find.text('Gioca'));
    await tester.tap(find.text('Gioca'));
    await tester.pump();

    expect(find.text('Cazzo hai scritto?!'), findsOneWidget);
    expect(find.text('Massimo 20 giocatori!'), findsOneWidget);
    expect(find.text('abc'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);

    await tester.enterText(fields.at(1), '4');
    await tester.enterText(fields.at(2), '5');
    await tester.ensureVisible(find.text('Gioca'));
    await tester.tap(find.text('Gioca'));
    await tester.pump();

    expect(find.text('Il valore 5 è fuori dal range!'), findsOneWidget);
  });

  testWidgets(
      'StartPage runs update check and explicit warning only when enabled on launch',
      (tester) async {
    Future<void> pumpStartPage({
      required bool checkForUpdate,
      required bool showExplicitContentWarning,
      required UpdateBloc updateBloc,
      required LoadBloc loadBloc,
    }) async {
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(value: loadBloc),
            BlocProvider.value(value: updateBloc),
          ],
          child: MaterialApp(
            key: ValueKey((checkForUpdate, showExplicitContentWarning)),
            home: StartPage(
              checkForUpdate: checkForUpdate,
              showExplicitContentWarning: showExplicitContentWarning,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
    }

    UpdateBloc makeUpdateBloc(FakeUpdateRepository repo) => UpdateBloc(
          checkForUpdate: CheckForUpdate(updateRepository: repo),
          downloadApk: DownloadApk(updateRepository: repo),
          installApk: InstallApk(updateRepository: repo),
          clearCachedUpdates: ClearCachedUpdates(updateRepository: repo),
          managePermission: ManageUpdatePermission(updateRepository: repo),
          permissionPromptDelay: Duration.zero,
        );

    final loadRepo = _StubLoadRepo(makeQuestions(), makeAnswers());
    final loadBloc = LoadBloc(
      loadQuestions: LoadQuestions(loadRepository: loadRepo),
      loadAnswers: LoadAnswers(loadRepository: loadRepo),
    );
    final skippedRepo = FakeUpdateRepository();
    final skippedUpdateBloc = makeUpdateBloc(skippedRepo);
    final bootRepo = FakeUpdateRepository();
    final bootUpdateBloc = makeUpdateBloc(bootRepo);
    addTearDown(() async {
      await loadBloc.close();
      await skippedUpdateBloc.close();
      await bootUpdateBloc.close();
    });

    await pumpStartPage(
      checkForUpdate: false,
      showExplicitContentWarning: false,
      updateBloc: skippedUpdateBloc,
      loadBloc: loadBloc,
    );
    await tester.pump(const Duration(seconds: 3));
    expect(skippedUpdateBloc.state, isA<UpdateInitial>());
    expect(skippedRepo.clearCacheCalls, equals(0));
    expect(find.text(explicitContentWarning), findsNothing);

    await pumpStartPage(
      checkForUpdate: true,
      showExplicitContentWarning: true,
      updateBloc: bootUpdateBloc,
      loadBloc: loadBloc,
    );
    expect(find.text(explicitContentWarning), findsOneWidget);
    expect(explicitContentWarning, contains('⚠️'));
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(bootUpdateBloc.state, isA<UpdateUpToDate>());
    expect(bootRepo.clearCacheCalls, equals(1));
  });

  testWidgets(
      'MasterGamePage shows validator error for bad chars and DataFailure instead of SnackBar',
      (tester) async {
    final repo = GameRepositoryImpl(
      randQuestionsSource:
          RandomQuestionsSource(seed: 123, questionList: makeQuestions()),
      randAnswersSource:
          RandomAnswersSource(seed: 123, answerList: makeAnswers()),
    );
    final gameBloc = GameBloc(
      retriveAnswers: RetriveAnswers(gameRepository: repo),
      drawNextQuestion: DrawNextQuestion(gameRepository: repo),
      drawNextAnswer: DrawNextAnswer(gameRepository: repo),
      playerNumber: 1,
      totalPlayers: 3,
    );
    addTearDown(gameBloc.close);

    gameBloc.add(const StartRound(isMaster: true));
    await expectLater(gameBloc.stream, emits(isA<RoundReady>()));

    await tester.pumpWidget(
      BlocProvider.value(
        value: gameBloc,
        child: const MaterialApp(home: MasterGamePage()),
      ),
    );

    final input = find.byType(TextField);
    await tester.enterText(input, '12a.34');
    await tester.tap(find.text('Mostra carte'));
    await tester.pump();

    expect(
      find.text('Caratteri non validi: usa solo numeri e ".", "," o "-"'),
      findsOneWidget,
    );

    // Commas and hyphens are accepted separators and reach DataFailure validation.
    await tester.enterText(input, '999, 999');
    await tester.runAsync(() async {
      await tester.tap(find.text('Mostra carte'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pump();

    expect(
      find.text(
        'Uno o più ID inseriti non appartengono ai mazzi degli altri giocatori',
      ),
      findsOneWidget,
    );
    expect(find.byType(SnackBar), findsNothing);

    await tester.enterText(input, '998-997');
    await tester.runAsync(() async {
      await tester.tap(find.text('Mostra carte'));
      await Future<void>.delayed(const Duration(milliseconds: 20));
    });
    await tester.pump();

    expect(
      find.text(
        'Uno o più ID inseriti non appartengono ai mazzi degli altri giocatori',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
      'MasterGamePage locks input under top card with responsive spacing and keeps button at bottom',
      (tester) async {
    Future<
        ({
          double topGap,
          double cardToFormGap,
          double formToButtonGap,
          double bottomGap,
        })> measureLayout(
      Size screenSize,
    ) async {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1.0;

      final repo = GameRepositoryImpl(
        randQuestionsSource:
            RandomQuestionsSource(seed: 123, questionList: makeQuestions()),
        randAnswersSource:
            RandomAnswersSource(seed: 123, answerList: makeAnswers()),
      );
      final gameBloc = GameBloc(
        retriveAnswers: RetriveAnswers(gameRepository: repo),
        drawNextQuestion: DrawNextQuestion(gameRepository: repo),
        drawNextAnswer: DrawNextAnswer(gameRepository: repo),
        playerNumber: 1,
        totalPlayers: 3,
      );
      addTearDown(gameBloc.close);

      gameBloc.add(const StartRound(isMaster: true));
      await expectLater(gameBloc.stream, emits(isA<RoundReady>()));

      await tester.pumpWidget(
        BlocProvider.value(
          value: gameBloc,
          child: const MaterialApp(home: MasterGamePage()),
        ),
      );

      final scaffoldRect = tester.getRect(find.byType(LayoutBuilder));
      final cardContainerRect = tester.getRect(
        find.descendant(
          of: find.byType(CardAHW),
          matching: find.byType(Container),
        ).first,
      );
      final formRect = tester.getRect(find.byType(Form));
      final buttonRect = tester.getRect(find.byType(CustomButton));

      return (
        topGap: cardContainerRect.top - scaffoldRect.top,
        cardToFormGap: formRect.top - cardContainerRect.bottom,
        formToButtonGap: buttonRect.top - formRect.bottom,
        bottomGap: scaffoldRect.bottom - buttonRect.bottom,
      );
    }

    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final phone = await measureLayout(const Size(400, 800));
    final tablet = await measureLayout(const Size(900, 1280));

    // Equal responsive gaps at top, between card & input, and at bottom (larger on tablet).
    expect(phone.topGap, closeTo(phone.bottomGap, 1.0));
    expect(phone.cardToFormGap, closeTo(phone.topGap, 1.0));
    expect(tablet.topGap, closeTo(tablet.bottomGap, 1.0));
    expect(tablet.cardToFormGap, closeTo(tablet.topGap, 1.0));
    expect(tablet.topGap, greaterThan(phone.topGap));
    expect(tablet.cardToFormGap, greaterThan(phone.cardToFormGap));

    // Remaining space pushes the button to the bottom while locking input under the card.
    expect(phone.formToButtonGap, greaterThan(phone.cardToFormGap));
    expect(tablet.formToButtonGap, greaterThan(tablet.cardToFormGap));
    expect(find.byType(CustomTextField), findsOneWidget);
  });
}
