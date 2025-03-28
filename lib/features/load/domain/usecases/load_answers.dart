import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Use case for answers loading.
class LoadAnswers implements UseCaseAsync<AnswerList> {
  /// Utility used to obtain the data from the data layer.
  LoadRepository loadRepository;

  LoadAnswers({required this.loadRepository});

  @override
  Future<Either<DataFailure, AnswerList>> call() async =>
      await loadRepository.getAnswers();
}
