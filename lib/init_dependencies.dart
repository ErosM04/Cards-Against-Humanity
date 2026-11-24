import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/core/models/answer_list_model.dart';
import 'package:cards_against_humanity/core/models/answer_model.dart';
import 'package:cards_against_humanity/core/models/question_list_model.dart';
import 'package:cards_against_humanity/core/models/question_model.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_answer_source.dart';
import 'package:cards_against_humanity/features/game/data/datasources/rand_question_source.dart';
import 'package:cards_against_humanity/features/game/data/repository/game_repo_impl.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_answer.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/draw_next_question.dart';
import 'package:cards_against_humanity/features/game/domain/usecases/retrive_answers.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';
import 'package:cards_against_humanity/features/load/data/repository/load_repository_impl.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_local_datasource.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_remote_datasource.dart';
import 'package:cards_against_humanity/features/update/data/repository/update_repository_impl.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/pick_and_install_apk.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:get_it/get_it.dart';

/// ``[GetIt]`` object used to locate a specific service (dependency).
///
/// To use call ``serviceLocator<ServiceName>()`` by specifing the *ServiceName*.
final serviceLocator = GetIt.instance;

/// Initializes varoious dependencies.
/// This is very useful to manage multiple dependencies, including **Blocs**.
///
/// For example if a want to call a bloc, in a provider i can just call **``serviceLocator()``** and specify the type of
/// dependency (or Bloc) to call:
/// ```
/// // Example with Bloc
/// BlocProvider(
///   create: (context) => serviceLocator<LoadBloc>(),
/// ),
/// ```
/// The ``[GetIt]`` object will automatically resolve the dependency.
Future<void> initDependencies() async {
  // By using registerLazySingleton we register a single instance (a Singleton) for a particular type
  // of dependency to share across the app.
  serviceLocator.registerLazySingleton(() => const CsvReader());
  _initLoad();
  _initUpdate();
}

/// Initializes all the dependencies (and sub-dependencies) related to the ``load`` feature.
///
/// Including:
/// - [LoadBloc]
///   - [LoadQuestions]
///   - [LoadAnswers]
///     - [LoadRepositoryImpl]
///     - [LoadLocalDataSourceImpl]
void _initLoad() {
  serviceLocator
    ..registerLazySingleton<LoadLocalDataSource>(
      () => LoadLocalDataSourceImpl(csvReader: serviceLocator()),
    )
    ..registerLazySingleton<LoadRepository>(
      () => LoadRepositoryImpl(localDataSource: serviceLocator()),
    )
    ..registerLazySingleton(
      () => LoadQuestions(loadRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => LoadAnswers(loadRepository: serviceLocator()),
    )
    // the bloc should have only one instance, otherwise if it has a particular state and it gets called from the app, it resets.
    ..registerLazySingleton(
      () => LoadBloc(
        loadQuestions: serviceLocator(),
        loadAnswers: serviceLocator(),
      ),
    );
}

/// Initializes all dependencies related to the `update` feature.
void _initUpdate() {
  serviceLocator
    ..registerLazySingleton<UpdateRemoteDataSource>(
      () => UpdateRemoteDataSourceImpl(),
    )
    ..registerLazySingleton<UpdateLocalDataSource>(
      () => const UpdateLocalDataSourceImpl(),
    )
    ..registerLazySingleton<UpdateRepository>(
      () => UpdateRepositoryImpl(
        remoteDataSource: serviceLocator(),
        localDataSource: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => CheckForUpdate(updateRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => DownloadApk(updateRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => InstallApk(updateRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => PickAndInstallApk(updateRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => ManageUpdatePermission(updateRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => UpdateBloc(
        checkForUpdate: serviceLocator(),
        downloadApk: serviceLocator(),
        installApk: serviceLocator(),
        pickAndInstallApk: serviceLocator(),
        managePermission: serviceLocator(),
      ),
    );
}

/// Initializes all the dependencies (and sub-dependencies) related to the ``game`` feature.
void initGameDependencies({
  required int seed,
  required int playerNumber,
  required int totalPlayers,
  required QuestionList questionList,
  required AnswerList answerList,
}) {
  if (serviceLocator.isRegistered<GameBloc>()) {
    serviceLocator.unregister<GameBloc>();
  }
  if (serviceLocator.isRegistered<DrawNextAnswer>()) {
    serviceLocator.unregister<DrawNextAnswer>();
  }
  if (serviceLocator.isRegistered<DrawNextQuestion>()) {
    serviceLocator.unregister<DrawNextQuestion>();
  }
  if (serviceLocator.isRegistered<RetriveAnswers>()) {
    serviceLocator.unregister<RetriveAnswers>();
  }
  if (serviceLocator.isRegistered<GameRepository>()) {
    serviceLocator.unregister<GameRepository>();
  }
  if (serviceLocator.isRegistered<RandomAnswersSource>()) {
    serviceLocator.unregister<RandomAnswersSource>();
  }
  if (serviceLocator.isRegistered<RandomQuestionsSource>()) {
    serviceLocator.unregister<RandomQuestionsSource>();
  }

  final qModel = questionList is QuestionListModel
      ? questionList
      : QuestionListModel(
          questions: List.generate(
            questionList.length,
            (i) => QuestionModel(
              id: questionList.getCardAt(i).id,
              text: questionList.getCardAt(i).text,
              answerNeeded: questionList.getCardAt(i).answerNeeded,
            ),
          ),
        );

  final aModel = answerList is AnswerListModel
      ? answerList
      : AnswerListModel(
          answers: List.generate(
            answerList.length,
            (i) => AnswerModel(
              id: answerList.getCardAt(i).id,
              text: answerList.getCardAt(i).text,
            ),
          ),
        );

  serviceLocator
    ..registerLazySingleton(
      () => RandomQuestionsSource(seed: seed, questionList: qModel),
    )
    ..registerLazySingleton(
      () => RandomAnswersSource(seed: seed, answerList: aModel),
    )
    ..registerLazySingleton<GameRepository>(
      () => GameRepositoryImpl(
        randQuestionsSource: serviceLocator(),
        randAnswersSource: serviceLocator(),
      ),
    )
    ..registerLazySingleton(
      () => DrawNextQuestion(gameRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => DrawNextAnswer(gameRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => RetriveAnswers(gameRepository: serviceLocator()),
    )
    ..registerLazySingleton(
      () => GameBloc(
        retriveAnswers: serviceLocator(),
        drawNextQuestion: serviceLocator(),
        drawNextAnswer: serviceLocator(),
        playerNumber: playerNumber,
        totalPlayers: totalPlayers,
      ),
    );
}
