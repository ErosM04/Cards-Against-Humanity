import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class LoadRepository {
  Future<Either<DataFailure, List<List<String>>>> getQuestions();
  Future<Either<DataFailure, List<String>>> getAnswers();
}
