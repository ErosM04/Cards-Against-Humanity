import 'package:cards_against_humanity/pages/components/card.dart';
import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:cards_against_humanity/pages/components/button.dart';
import 'package:cards_against_humanity/pages/game_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/pages/start_page.dart';
import 'package:cards_against_humanity/pages/components/textfield.dart';
import 'package:flutter/material.dart';

/// Page of the player which has to insert the ids of the cards selected by the other players.
class MasterGamePage extends StatefulWidget {
  /// The object that manages the logic of the game.
  final CasualityManager random;

  const MasterGamePage(this.random, {super.key});

  @override
  State<MasterGamePage> createState() => _MasterGamePageState();
}

class _MasterGamePageState extends State<MasterGamePage> {
  /// The list of answer cards that will be inserted by the player.
  List<String> answerCardList = [];

  /// The controller of the [TextField] where the players inserts the ids of the answer cards.
  final textController = TextEditingController();

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
                onClicked: () => null,
                text: widget.random.question,
                isClickable: false,
              ),
              const SizedBox(height: 50),
              // Those ifs are to hide element on setState()
              // This is an abort in the form of lines of code that hides the textfield when the button is pressed
              // and then shows the list of cards containing the answers.
              (answerCardList.isEmpty)
                  ? _buildSubTitle('Inserisci i numeri delle carte:',
                      fontSize: 22)
                  : Container(),
              (answerCardList.isEmpty)
                  ? _buildSubTitle('es: 11.22.104',
                      fontSize: 18, verticalPadding: 2)
                  : Container(),
              (answerCardList.isEmpty)
                  ? CustomTextField(controller: textController)
                  : Container(),
              (answerCardList.isEmpty)
                  ? _buildButton(
                      text: 'Mostra carte', onPressed: () => _getAnswerCards())
                  : Container(),
              (answerCardList.isNotEmpty)
                  ? _buildCardCarousel(answerCardList)
                  : Container(),
              (answerCardList.isNotEmpty)
                  ? _buildButton(
                      text: 'Prossimo round', onPressed: () => _goToNewRound())
                  : Container(),
            ]),
          ),
        ),
      );

  /// Read the data from the textfield, converts it into a list of numbers and then use these ids to get the answers and returns a list
  /// of answers that is save in [answerCardList].
  void _getAnswerCards() {
    String str = textController.text
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('-', '');

    if (str.contains('.') &&
        (str.split('.').length ==
            (CasualityManager.answersNeeded *
                (widget.random.totalPlayers - 1)))) {
      final splitArr = str.split('.');

      // If data inserted aren't numbers the function stops
      for (var element in splitArr) {
        if (int.tryParse(element) == null) return;
      }

      // Converts the array of number into an array with the corresponding answer
      final List<String> answerList = widget.random.revealAnswerCards(
          List<int>.generate(
              splitArr.length, (index) => int.parse(splitArr[index])));

      if (answerList.length ==
          (CasualityManager.answersNeeded * (widget.random.totalPlayers - 1))) {
        // True if only 1 answer per player is requested
        if (answerList.length == (widget.random.totalPlayers - 1)) {
          answerList.shuffle();
          setState(() => answerCardList = answerList);
        } else {
          List<List<String>> bigList = [];
          for (var i = 0; i < answerList.length; i += 2) {
            bigList.add([answerList[i], answerList[i + 1]]);
          }

          bigList.shuffle();

          List<String> resultList = [];
          for (List<String> list in bigList) {
            for (var i = 0; i < list.length; i += 2) {
              resultList.add('${list[i]}\n\n${list[i + 1]}');
            }
          }
          setState(() => answerCardList = resultList);
        }
      }
    }
  }

  /// Goes to the normal game page.
  void _goToNewRound() {
    // As the cards can be clicked, they alter the list of selectedCards, so here is cleared
    CasualityManager.selectedCards.clear();
    widget.random.fillHand();
    widget.random.drawQuestionCard();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => GamePage(widget.random)));
  }

  /// Builds a [CustomButton] to reveal the answer cards or to move to the next page.
  Widget _buildButton({
    required String text,
    required void Function() onPressed,
  }) =>
      Padding(
          padding: const EdgeInsets.symmetric(vertical: 50),
          child: CustomButton(
            text: text,
            onPressed: onPressed,
          ));

  /// Takes a list of answers and build a horizontal list of [CardAH] containg the different answers of the different
  /// players (shuffled).
  Widget _buildCardCarousel(List<String> list) => SizedBox(
        height: 220,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CardAH(
                  text: list[index],
                  onClicked: () {},
                )),
      );

  /// Builds a customizable subtitle
  Widget _buildSubTitle(
    String text, {
    double fontSize = 24,
    double horizontalPadding = 20,
    double verticalPadding = 0,
  }) =>
      Padding(
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
