import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/pages/appbar.dart';
import 'package:cards_against_humanity/pages/card_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/pages/start_page.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final CasualityManager random;

  const GamePage(this.random, {super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: CustomAppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_sharp),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const StartPage())),
          ),
          actions: [
            SizedBox(
              width: 65,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Text(
                  '${widget.random.score}/${calculateScore()}',
                  style: TextStyle(
                      fontSize: 17,
                      color: Theme.of(context).colorScheme.secondary),
                ),
                onPressed: () {},
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              const SizedBox(height: 30),
              CardAH(
                onClicked: () => null,
                text: widget.random.question,
                isClickable: false,
              ),
              const SizedBox(height: 100),
              buildSubTitle('La tua mano:'),
              const SizedBox(height: 20),
              buildCardCarousel(widget.random.hand),
            ]),
          ),
        ),
      );

  /// Calculates the amount of rounds played by the user, excluding the rounds played as master.
  int calculateScore() =>
      (widget.random.round - 1) -
      ((widget.random.round / widget.random.totalPlayers).floor() +
          ((widget.random.round % widget.random.totalPlayers) /
                      widget.random.playerNumber >=
                  1
              ? 1
              : 0));

  Padding buildSubTitle(String text,
      {double fontSize = 24,
      double horizontalPadding = 20,
      double verticalPadding = 0}) {
    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: verticalPadding),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Takes a list of answers and build a horizontal list of card using the [CardAH] widget.
  /// Every time a card widget is clicked the method [selectCard] is called.
  Widget buildCardCarousel(List<String> list) => SizedBox(
        height: 220,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CardAH(
                onClicked: () => selectCard(list[index]), text: list[index])),
      );

  /// Takes the text of the clicked card and if all the cards needed were selected proceeds to redirect the user to the rigth page.
  /// #### Parameters
  /// - ``String [text]`` : the text of the card that has been clicked.
  void selectCard(String text) {
    if (CasualityManager.selectedCards.length ==
        CasualityManager.answerNeeded) {
      for (var cardText in CasualityManager.selectedCards) {
        widget.random.useCard(cardText);
      }

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CardPage(widget.random)));
    }
  }
}
