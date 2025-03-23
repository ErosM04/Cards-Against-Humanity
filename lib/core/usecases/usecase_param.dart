import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Basic use case with parameters.
abstract interface class UseCaseParam<SuccessType, Param> {
  /// Method used to perform the specific usecase that can return a failure or a success.
  Either<Failure, SuccessType> call(Param param);
}

/// Basic asynchronous use case with parameters.
abstract interface class UseCaseAsyncParam<SuccessType, Param> {
  /// Method used to perform the specific usecase that can return a failure or a success.
  Future<Either<Failure, SuccessType>> call(Param param);
}
