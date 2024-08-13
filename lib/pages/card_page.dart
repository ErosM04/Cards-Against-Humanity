import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:cards_against_humanity/pages/components/button.dart';
import 'package:cards_against_humanity/pages/game_page.dart';
import 'package:cards_against_humanity/pages/master_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  final CasualityManager random;

  const CardPage(this.random, {super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: const CustomAppBar(),
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
                    onPressed: () => widget.random.lost(),
                    color: Colors.red,
                  ),
                  _buildEndButton(
                    text: 'Ho vinto',
                    onPressed: () => widget.random.won(),
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        ),
      ));

  /// Used to build a the ``Ho perso`` and ``Ho vinto`` buttons.
  Widget _buildEndButton(
          {required String text,
          required Function onPressed,
          required Color color}) =>
      CustomButton(
          text: text,
          textColor: Colors.white,
          fontSize: 20,
          verticalInternalPadding: 12,
          color: color,
          onPressed: () {
            onPressed();
            _goToNewRound();
          });

  /// Used to build the complete card with the question and all the answer.
  /// Answers are in a different color.
  Widget _buildCompleteCard() => Column(
        children: [
          CardAH(
            onClicked: () => null,
            text: widget.random.question,
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

  /// Goes to a MasterGamePage if the next round is the round of the actual player, otherwise goes to a GamePage.
  void _goToNewRound() {
    widget.random.fillHand();
    widget.random.drawQuestionCard();

    // The first condition is true if, for ex, there are 4 players and the actual player is the 4th (so it's his turn).
    // The secon condition is true if, for ex, the user is the player 1 and there are 4 player and is the round 5:
    // 5 % 4 = 1, which is equal to the number player number (1).
    (((widget.random.round % widget.random.totalPlayers) == 0 &&
                (widget.random.playerNumber == widget.random.totalPlayers)) ||
            (widget.random.round % widget.random.totalPlayers) ==
                widget.random.playerNumber)
        ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => MasterGamePage(widget.random)))
        : Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => GamePage(widget.random)));
  }
}
