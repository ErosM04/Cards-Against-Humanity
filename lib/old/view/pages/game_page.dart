import 'package:cards_against_humanity/old/view/components/card.dart';
import 'package:cards_against_humanity/old/view/components/appbar.dart';
import 'package:cards_against_humanity/old/view/pages/card_page.dart';
import 'package:cards_against_humanity/old/gamelogic/logic.dart';
import 'package:cards_against_humanity/features/start/presentation/pages/start_page.dart';
import 'package:flutter/material.dart';

/// The normal Game page, where the player has to choose the funniest answer/s card/s to complete the
/// question card.
class GamePage extends StatefulWidget {
  /// The object that manages the logic of the game.
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
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const StartPage())),
          ),
          score: widget.random.score,
          maxPoints: widget.random.playedRounds,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(children: [
              const SizedBox(height: 30),
              CardAH(
                text: widget.random.question,
                isClickable: false,
                isMainCard: true,
              ),
              const SizedBox(height: 100),
              _buildSubTitle('La tua mano:'),
              const SizedBox(height: 20),
              _buildCardCarousel(widget.random.hand),
            ]),
          ),
        ),
      );

  /// Builds the subtitles
  Widget _buildSubTitle(
    String text, {
    double fontSize = 24,
    double horizontalPadding = 20,
    double verticalPadding = 0,
  }) {
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
  /// Every time a card widget is clicked the method [_selectCard] is called.
  Widget _buildCardCarousel(List<String> list) => SizedBox(
        height: 220,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CardAH(
                onClicked: () => _selectCard(list[index]), text: list[index])),
      );

  /// Takes the text of the clicked card and if all the cards needed were selected proceeds to redirect the user to the rigth page.
  /// #### Parameters
  /// - ``String [text]`` : the text of the card that has been clicked.
  void _selectCard(String text) {
    if (CasualityManager.selectedCards.length ==
        CasualityManager.answersNeeded) {
      for (var cardText in CasualityManager.selectedCards) {
        widget.random.useCard(cardText);
      }

      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => CardPage(widget.random)));
    }
  }
}
