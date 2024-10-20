import 'package:cards_against_humanity/features/load/domain/entities/question_list.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/usecase.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for question loading.
class LoadQuestions implements UseCase<QuestionList> {
  final LoadRepository loadRepository;

  const LoadQuestions({required this.loadRepository});

  @override
  Future<Either<DataFailure, QuestionList>> call() async =>
      await loadRepository.getQuestions();
}
