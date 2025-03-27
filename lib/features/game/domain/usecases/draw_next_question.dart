import 'package:cards_against_humanity/core/entities/data/question.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Draws a [Question] card.
class DrawNextQuestion implements UseCase<Question> {
  final GameRepository gameRepository;

  const DrawNextQuestion({required this.gameRepository});

  @override
  Either<Failure, Question> call() => gameRepository.drawQuestionCard();
}
