import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Basic use case with no parameters.
abstract interface class UseCase<SuccessType> {
  /// Method used to perform the specific usecase that can return a failure or a success.
  Either<Failure, SuccessType> call();
}

/// Basic asynchronous use case with no parameters.
abstract interface class UseCaseAsync<SuccessType> {
  /// Method used to perform the specific usecase that can return a failure or a success.
  Future<Either<Failure, SuccessType>> call();
}
