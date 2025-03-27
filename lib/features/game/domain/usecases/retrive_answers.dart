import 'package:cards_against_humanity/core/entities/data/answer.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/core/usecases/usecase_param.dart';
import 'package:cards_against_humanity/features/game/domain/repository/game_repository.dart';
import 'package:fpdart/fpdart.dart';

/// Takes a list of ids, where each id is the identifier of an [Answer] card and returns an [AnswerList]
/// containg all the [Answer]s with that specific id.
class RetriveAnswers implements UseCaseParam<AnswerList, List<int>> {
  final GameRepository gameRepository;

  const RetriveAnswers({required this.gameRepository});

  @override
  Either<DataRangeFailure, AnswerList> call(List<int> ids) =>
      gameRepository.retriveAnswers(ids);
}
