import 'package:cards_against_humanity/core/error/exceptions.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:fpdart/fpdart.dart';

class LoadRepositoryImpl implements LoadRepository {
  final LoadLocalDataSource localDataSource;

  const LoadRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<DataFailure, List<List<String>>>> getQuestions() async {
    try {
      return right(await localDataSource.getQuestions());
    } on DataLoadException catch (e) {
      return left(DataFailure(e.message, dataType: List<List<String>>));
    }
  }

  @override
  Future<Either<DataFailure, List<String>>> getAnswers() async {
    try {
      return right(await localDataSource.getAnswers());
    } on DataLoadException catch (e) {
      return left(DataFailure(e.message, dataType: List<String>));
    }
  }
}
