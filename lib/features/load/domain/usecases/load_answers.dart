import 'package:fpdart/fpdart.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/usecase.dart';

class LoadAnswers implements UseCase<List<String>> {
  LoadRepository loadRepository;

  LoadAnswers({required this.loadRepository});

  @override
  Future<Either<Failure, List<String>>> call() async =>
      await loadRepository.getAnswers();
}
