import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/pages/appbar.dart';
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
              buildCompleteCard(),
              const SizedBox(height: 100),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildEndButton(
                      text: 'Ho perso',
                      color: Colors.red,
                      function: () {
                        widget.random.lost();
                        goToNewRound();
                      }),
                  buildEndButton(
                      text: 'Ho vinto',
                      color: Colors.green,
                      function: () {
                        widget.random.won();
                        goToNewRound();
                      }),
                ],
              ),
            ],
          ),
        ),
      ));

  /// Used to build a the ``Ho perso`` and ``Ho vinto`` buttons.
  ElevatedButton buildEndButton(
          {required String text,
          required Function function,
          required Color color}) =>
      ElevatedButton(
          onPressed: () => function(),
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ));

  /// Used to build the complete card with the question and all the answer.
  /// Answers are in a different color.
  Widget buildCompleteCard() => Column(
        children: [
          CardAH(
            onClicked: () => null,
            text: widget.random.question,
            isClickable: false,
            answersList: CasualityManager.selectedCards,
          ),
          const SizedBox(height: 10),
          Text('ID carta/e: ${extractCardsId()}'),
        ],
      );

  /// Extracts the ids of the card saved in ``CasualityManager.selectedCards``. E.g.: "121, 557"
  String extractCardsId() => List<String>.generate(
          CasualityManager.selectedCards.length,
          (index) => CasualityManager.selectedCards[index].split('-')[0].trim())
      .toString()
      .replaceAll('[', '')
      .replaceAll(']', '');

  /// Goes to a MasterGamePage if the next round is the round of the actual player, otherwise goes to a GamePage.
  void goToNewRound() {
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
