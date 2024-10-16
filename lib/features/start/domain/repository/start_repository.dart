import 'package:cards_against_humanity/core/error/failure.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class StartRepository {
  Either<Failure, String> startGame();
}
