import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';
import 'package:cards_against_humanity/core/usecase/usecase.dart';

/// We define the ``[SuccessType]`` in order not to hard code the type of data of the success in the [LoadUseCase] class.
abstract interface class LoadUseCase<SuccessType> implements UseCase {
  /// Method used to perform the specific load usecase that can return a failure or a success.
  @override
  Future<Either<Failure, SuccessType>> call();
}
