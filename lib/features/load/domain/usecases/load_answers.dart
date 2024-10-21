import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/usecase.dart';

/// Use case for answers loading.
class LoadAnswers implements UseCase<AnswerList> {
  LoadRepository loadRepository;

  LoadAnswers({required this.loadRepository});

  @override
  Future<Either<DataFailure, AnswerList>> call() async =>
      await loadRepository.getAnswers();
}
