import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Implements the [LoadRepository] by defining how every method peforms the actions (using the `data source`)
/// and returns the result, or return a [Failure].
/// This class act as a conduit between the data layer (datasource) and the domain layer (usecases).
class LoadRepositoryImpl implements LoadRepository {
  /// The data source that manages the local table of questions and answers.
  final LoadLocalDataSource localDataSource;

  const LoadRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<DataFailure, QuestionList>> getQuestions() async {
    try {
      return right((await localDataSource.getQuestions()));
    } on DataLoadException catch (e) {
      return left(DataFailure(e.message, dataType: LoadLocalDataSource));
    }
  }

  @override
  Future<Either<DataFailure, AnswerList>> getAnswers() async {
    try {
      return right(await localDataSource.getAnswers());
    } on DataLoadException catch (e) {
      return left(DataFailure(e.message, dataType: LoadLocalDataSource));
    }
  }
}
