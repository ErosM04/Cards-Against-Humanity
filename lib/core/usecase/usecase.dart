import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// Basic use case.
abstract interface class UseCase<SuccessType> {
  /// Method used to perform the specific usecase that can return a failure or a success.
  Future<Either<Failure, SuccessType>> call();
}
