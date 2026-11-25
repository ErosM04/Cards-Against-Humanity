import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Parameters for validating and fetching played [Answer] cards.
class RetriveAnswersParams {
  /// Answer card IDs submitted by the Master player.
  final List<int> ids;

  /// Pool of answer card IDs currently eligible across other players' hands.
  final List<int> eligibleIds;

  const RetriveAnswersParams({
    required this.ids,
    required this.eligibleIds,
  });
}

/// Validates requested [Answer] IDs against other players' eligible decks and returns them.
class RetriveAnswers implements UseCaseParam<AnswerList, RetriveAnswersParams> {
  /// Utility used to obtain the data from the data layer.
  final GameRepository gameRepository;

  const RetriveAnswers({required this.gameRepository});

  @override
  Either<Failure, AnswerList> call(RetriveAnswersParams params) {
    final remaining = List<int>.from(params.eligibleIds);
    for (final id in params.ids) {
      if (!remaining.remove(id)) {
        return left(
          DataFailure(
            'Uno o più ID inseriti non appartengono ai mazzi degli altri giocatori',
            dataType: AnswerList,
          ),
        );
      }
    }
    return gameRepository.retriveAnswers(params.ids);
  }
}
