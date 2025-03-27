import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Draws an [Answer] card for each player and then returns only the one corresponding
/// to the actual player.
class DrawNextAnswer implements UseCaseParam<Answer, DrawAnswerParams> {
  final GameRepository gameRepository;

  const DrawNextAnswer({required this.gameRepository});

  @override
  Either<Failure, Answer> call(DrawAnswerParams params) {
    var res = gameRepository.drawAnswerCards(params.totalPlayers);
    return res.fold(
      (fail) => Left(fail),
      (answers) => Right(answers.getCardAt(params.playerNumber - 1)),
    );
  }
}

/// The class used to store the parameters for the [DrawNextAnswer] usecase.
class DrawAnswerParams {
  /// The total number of players.
  final int totalPlayers;

  /// The specific number of the player between 0 and ``[totalPlayers]``.
  final int playerNumber;

  const DrawAnswerParams({
    required this.totalPlayers,
    required this.playerNumber,
  });
}
