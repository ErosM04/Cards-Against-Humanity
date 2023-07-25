import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/game/game_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/textfield.dart';
import 'package:flutter/material.dart';

class MasterGamePage extends StatefulWidget {
  final CasualityManager random;

  const MasterGamePage(this.random, {super.key});

  @override
  State<MasterGamePage> createState() => _MasterGamePageState();
}

class _MasterGamePageState extends State<MasterGamePage> {
  List<String> answerCardList = [];
  final textController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Cards Against Humanity',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
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
              (answerCardList.isEmpty)
                  ? buildSubTitle('Inserisci i numeri delle carte:',
                      fontSize: 22)
                  : Container(),
              (answerCardList.isEmpty)
                  ? buildSubTitle('es: 11,22,104',
                      fontSize: 18, verticalPadding: 2)
                  : Container(),
              (answerCardList.isEmpty)
                  ? CustomTextField(controller: textController)
                  : Container(),
              (answerCardList.isEmpty)
                  ? buildButton(
                      text: 'Mostra carte',
                      function: () {
                        String str = textController.text
                            .replaceAll(' ', '')
                            .replaceAll('.', '')
                            .replaceAll('-', '');

                        if (str.contains(',') &&
                            (str.split(',').length ==
                                    (CasualityManager.answerNeeded * 3) ||
                                str.split(',').length == 6)) {
                          final splitArr = str.split(',');
                          final List<String> answerList = widget.random
                              .revealAnswerCards(List<int>.generate(
                                  splitArr.length,
                                  (index) => int.parse(splitArr[index])));
                          if (answerList.length ==
                              (CasualityManager.answerNeeded * 3)) {
                            if (answerList.length == 3) {
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
                                  resultList
                                      .add('${list[i]}\n\n${list[i + 1]}');
                                }
                              }
                              setState(() => answerCardList = resultList);
                            }
                          }
                        }
                      })
                  : Container(),
              (answerCardList.isNotEmpty)
                  ? buildCardCarousel(answerCardList)
                  : Container(),
              (answerCardList.isNotEmpty)
                  ? buildButton(
                      text: 'Prossimo round',
                      function: () {
                        // As the cards can be clicked, they alter the list of selectedCards, so here is cleared
                        CasualityManager.selectedCards.clear();
                        widget.random.fillHand();
                        widget.random.drawQuestionCard();
                        // As this round couldn't be played by the actual player, is not counted
                        widget.random.addUncountableRound();
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => GamePage(widget.random)));
                      })
                  : Container(),
            ]),
          ),
        ),
      );

  Padding buildButton({required String text, required Function function}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 50),
        child: ElevatedButton(
          onPressed: () => function(),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                      fontSize: 25, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      );

  Widget buildCardCarousel(List<String> list) => SizedBox(
        height: 200,
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
}
