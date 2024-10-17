import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LoadRepository {
  Future<Either<Failure, List<List<String>>>> getQuestions();
  Future<Either<Failure, List<String>>> getAnswers();
}
