import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';
import 'package:cards_against_humanity/features/load/data/repository/load_repository_impl.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

/// Initializes varoious dependencies.
/// This is very useful to manage multiple dependencies, including **Blocs**.
///
/// For example if a want to call a bloc, in a provider i can just call **``serviceLocator()``** and specify the type of
/// dependency (or Bloc) to call:
/// ```
/// BlocProvider(
///   create: (context) => serviceLocator<LoadBloc>(),
/// ),
/// ```
/// The ``[GetIt]`` object will automatically resolve the dependency.
Future<void> initDependencies() async {
  // By using registerLazySingleton we register a single instance (a Singleton) for a particular type
  // of dependency to share across the app.
  serviceLocator.registerLazySingleton(() => CsvReader());
  _initLoad();
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
  serviceLocator.registerLazySingleton<LoadLocalDataSource>(
    () => LoadLocalDataSourceImpl(csvReader: serviceLocator()),
  );

  serviceLocator.registerLazySingleton<LoadRepository>(
    () => LoadRepositoryImpl(localDataSource: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => LoadQuestions(loadRepository: serviceLocator()),
  );

  serviceLocator.registerLazySingleton(
    () => LoadQuestions(loadRepository: serviceLocator()),
  );

  // the bloc should have only one instance, otherwise if it has a particular state and it gets called from the app, it resets.
  serviceLocator.registerLazySingleton(
    () => LoadBloc(
      loadQuestions: serviceLocator(),
      loadAnswers: serviceLocator(),
    ),
  );
}
