import 'package:fpdart/fpdart.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/features/load/domain/repository/start_repository.dart';

class LoadRepositoryImpl implements LoadRepository {
  final LoadLocalDataSource localDataSource;

  const LoadRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, String>> getAnswers() async {
    try {} catch (e) {}
  }

  @override
  Future<Either<Failure, String>> getQuestions() async {}
}
