import 'package:cards_against_humanity/pages/components/card.dart';
import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:cards_against_humanity/pages/components/button.dart';
import 'package:cards_against_humanity/pages/game_page.dart';
import 'package:cards_against_humanity/pages/master_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:flutter/material.dart';

/// The page that is displayed after the **Game page** and shows the question card, with the answer/s previously
/// selected by the player that fills the empty spots. The answer text color follows the [Theme] of the app.
class CardPage extends StatelessWidget {
  /// The object that manages the logic of the game.
  final CasualityManager random;

  const CardPage(this.random, {super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: CustomAppBar(score: random.score, maxPoints: random.playedRounds),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCompleteCard(),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildEndButton(
                    text: 'Ho perso',
                    onPressed: () => random.lost(),
                    color: Colors.red,
                    context: context,
                  ),
                  _buildEndButton(
                    text: 'Ho vinto',
                    onPressed: () => random.won(),
                    color: Colors.green,
                    context: context,
                  ),
                ],
              ),
            ],
          ),
        ),
      ));

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
  Widget _buildCompleteCard() => Column(
        children: [
          CardAH(
            onClicked: () => null,
            text: random.question,
            isClickable: false,
            answersList: CasualityManager.selectedCards,
          ),
          const SizedBox(height: 10),
          Text('ID carta/e: ${_extractCardsId()}'),
        ],
      );

  /// Extracts the ids of the card saved in ``CasualityManager.selectedCards``. E.g.: "121, 557"
  String _extractCardsId() => List<String>.generate(
          CasualityManager.selectedCards.length,
          (index) => CasualityManager.selectedCards[index].split('-')[0].trim())
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '');

  /// Goes to a Master page if the next round is the round of the actual player, otherwise goes to the Game page.
  void _goToNewRound(BuildContext context) {
    random.fillHand();
    random.drawQuestionCard();

    // The first condition is true if, for ex, there are 4 players and the actual player is the 4th (so it's his turn).
    // The secon condition is true if, for ex, the user is the player 1 and there are 4 player and is the round 5:
    // 5 % 4 = 1, which is equal to the number player number (1).
    (((random.round % random.totalPlayers) == 0 &&
                (random.playerNumber == random.totalPlayers)) ||
            (random.round % random.totalPlayers) == random.playerNumber)
        ? Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MasterGamePage(random)))
        : Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => GamePage(random)));
  }
}
