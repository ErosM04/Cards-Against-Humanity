import 'dart:math';
import 'package:cards_against_humanity/data_reader.dart';
import 'package:cards_against_humanity/game/game_page.dart';
import 'package:cards_against_humanity/game/master_page.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/textfield.dart';
import 'package:cards_against_humanity/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CardsAgainstHumanity());

class CardsAgainstHumanity extends StatelessWidget {
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Against Humanity',
      theme: appTheme,
      home: const StartPage(title: 'Cards Against Humanity'),
    );
  }
}

class StartPage extends StatefulWidget {
  final String title;
  final CsvReader csvReader = const CsvReader();

  const StartPage({super.key, required this.title});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final seedController = TextEditingController();
  final playerNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            'Cards Against Humanity',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Codice partita:',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                CustomTextField(controller: seedController),
                const SizedBox(height: 100),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Numero giocatore:',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                CustomTextField(controller: playerNumberController),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: ElevatedButton(
                    onPressed: () => startGame(),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Play',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  void startGame() {
    if (seedController.text.replaceAll(' ', '').isNotEmpty &&
        (playerNumberController.text.replaceAll(' ', '') == '1' ||
            playerNumberController.text.replaceAll(' ', '') == '2' ||
            playerNumberController.text.replaceAll(' ', '') == '3' ||
            playerNumberController.text.replaceAll(' ', '') == '4')) {
      try {
        int? seed = int.tryParse(seedController.text
            .replaceAll(' ', '')
            .replaceAll('.', '')
            .replaceAll('-', ''));
        int? playerNumber = int.tryParse(playerNumberController.text
            .replaceAll(' ', '')
            .replaceAll('.', '')
            .replaceAll('-', ''));
        if (seed != null && playerNumber != null) {
          List<List<dynamic>> questionList = [];
          widget.csvReader.getQuestions().then((list) {
            questionList = list;
            return widget.csvReader.getAnswers();
          }).then((answerList) {
            CasualityManager rand = CasualityManager(
              seed: seed,
              playerNumber: playerNumber,
              randomAnswerCard: Random(seed),
              randomQuestionCard: Random(seed + 1),
              questionList: questionList,
              answerList: answerList,
            );

            // If this is the 1st player starts as a master
            return (playerNumber == 1)
                ? Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MasterGamePage(rand)))
                : Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => GamePage(rand)));
          });
        } else {
          setState(() => seedController.text = 'Cojion');
        }
      } catch (e) {
        setState(() => seedController.text = 'Cojion');
      }
    }
  }
}
