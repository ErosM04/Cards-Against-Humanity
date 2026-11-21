import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/game_page.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/master_page.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:cards_against_humanity/old/view/components/appbar.dart';
import 'package:cards_against_humanity/old/view/components/button.dart';
import 'package:cards_against_humanity/old/view/components/card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The page that is displayed after the **Game page** and shows the question card, with the answer/s previously
/// selected by the player that fills the empty spots. The answer text color follows the [Theme] of the app.
class CardPage extends StatelessWidget {
  const CardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    return Scaffold(
      appBar: CustomAppBar(
        score: gameBloc.gameData.score,
        maxPoints: gameBloc.gameData.playerRounds,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompleteCard(gameBloc),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEndButton(
                    text: 'Ho perso',
                    onPressed: () {
                      context.read<GameBloc>().add(const RoundLost());
                    },
                    color: Colors.red,
                    context: context,
                  ),
                  _buildEndButton(
                    text: 'Ho vinto',
                    onPressed: () {
                      context.read<GameBloc>().add(const RoundWon());
                    },
                    color: Colors.green,
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Used to build a the ``Ho perso`` and ``Ho vinto`` buttons.
  Widget _buildEndButton({
    required String text,
    required Function onPressed,
    required Color color,
    required BuildContext context,
  }) =>
      CustomButton(
        text: text,
        textColor: Colors.white,
        fontSize: 20,
        verticalInternalPadding: 12,
        color: color,
        onPressed: () {
          onPressed();
          _goToNewRound(context);
        },
      );

  /// Used to build the complete card with the question and all the answer.
  /// Answers are in a different color.
  Widget _buildCompleteCard(GameBloc gameBloc) {
    final selectedTexts =
        gameBloc.selectedCards.map((c) => '${c.id} - ${c.text}').toList();
    return Column(
      children: [
        CardAHW(
          text: gameBloc.currentQuestion?.text ?? '',
          isClickable: false,
          isMainCard: true,
          answersList: selectedTexts,
        ),
        const SizedBox(height: 10),
        Text('ID carta/e: ${_extractCardsId(gameBloc)}'),
      ],
    );
  }

  /// Extracts the ids of the selected cards. E.g.: "121, 557"
  String _extractCardsId(GameBloc gameBloc) =>
      gameBloc.selectedCards.map((c) => c.id.toString()).join(', ');

  /// Goes to a Master page if the next round is the round of the actual player, otherwise goes to the Game page.
  void _goToNewRound(BuildContext context) {
    final gameBloc = context.read<GameBloc>();
    final nextRound = gameBloc.gameData.totalRounds + 1;
    final isNextMaster = gameBloc.gameData.isMasterForRound(nextRound);

    gameBloc.add(StartRound(isMaster: isNextMaster));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: serviceLocator<GameBloc>(),
          child: isNextMaster ? const MasterGamePage() : const GamePage(),
        ),
      ),
    );
  }
}
