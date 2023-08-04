import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/pages/card_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
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
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Cards Against Humanity',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
          actions: [
            SizedBox(
              width: 65,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Expanded(
                  child: Text(
                    '${widget.random.score}/${widget.random.round - widget.random.skippedRounds}',
                    style: TextStyle(
                        fontSize: 17,
                        color: Theme.of(context).colorScheme.secondary),
                  ),
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

  Widget buildCardCarousel(List<String> list) => SizedBox(
        height: 200,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CardAH(
                onClicked: () => selectCard(list[index]), text: list[index])),
      );

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
