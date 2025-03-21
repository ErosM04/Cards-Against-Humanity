import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:cards_against_humanity/core/usecase/usecase.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class GameUseCase<SuccessType> implements UseCase {
  @override
  Future<Either<Failure, SuccessType>> call();
}
