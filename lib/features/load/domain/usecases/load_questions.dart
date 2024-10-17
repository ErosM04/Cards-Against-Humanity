import 'package:fpdart/fpdart.dart';
import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/features/load/domain/repository/load_repository.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/usecase.dart';

class LoadQuestions implements UseCase<List<List<String>>> {
  final LoadRepository loadRepository;

  const LoadQuestions({required this.loadRepository});

  @override
  Future<Either<Failure, List<List<String>>>> call() async =>
      await loadRepository.getQuestions();
}
