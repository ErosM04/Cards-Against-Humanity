import 'package:cards_against_humanity/core/error/failures.dart';
import 'package:fpdart/fpdart.dart';

/// We define the ``[SuccessType]`` in order not to hard code the type of data of the success in the [UseCase] class.
abstract interface class UseCase<SuccessType> {
  Future<Either<DataFailure, SuccessType>> call();
}
