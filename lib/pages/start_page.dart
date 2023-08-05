import 'dart:math';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/model/data_reader.dart';
import 'package:cards_against_humanity/pages/easteregg.dart';
import 'package:cards_against_humanity/pages/game_page.dart';
import 'package:cards_against_humanity/pages/master_page.dart';
import 'package:cards_against_humanity/textfield.dart';
import 'package:flutter/material.dart';

class StartPage extends StatefulWidget {
  final CsvReader csvReader = const CsvReader();

  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  final seedController = TextEditingController();
  final playerAmountController = TextEditingController();
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
                // Seed
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
                // Total players
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'Totale giocatori:',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),
                CustomTextField(controller: playerAmountController),
                const SizedBox(height: 100),
                // Player number
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
    // Cheks if the data in the textfields are in the wrong format
    if (!(seedController.text.replaceAll(' ', '').isNotEmpty &&
        (playerAmountController.text.replaceAll(' ', '').isNotEmpty &&
            int.tryParse(playerAmountController.text.replaceAll(' ', '')) !=
                null) &&
        (playerNumberController.text.replaceAll(' ', '') == '1' ||
            playerNumberController.text.replaceAll(' ', '') == '2' ||
            playerNumberController.text.replaceAll(' ', '') == '3' ||
            playerNumberController.text.replaceAll(' ', '') == '4'))) {
      cojion();
      return;
    }
    int? seed = int.tryParse(seedController.text
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll('-', ''));
    int? playerAmount = int.tryParse(playerAmountController.text
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll('-', ''));
    int? playerNumber = int.tryParse(playerNumberController.text
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll('-', ''));

    if (seed == null ||
        playerAmount == null ||
        playerNumber == null ||
        playerNumber > playerAmount) {
      cojion();
      return;
    }

    List<List<dynamic>> questionList = [];
    widget.csvReader.getQuestions().then((list) {
      questionList = list;
      return widget.csvReader.getAnswers();
    }).then((answerList) {
      //Easter egg
      if (seed == 104) {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EasterEgg(Random().nextInt(10))));
      } else {
        CasualityManager rand = CasualityManager(
          seed: seed,
          playerNumber: playerNumber,
          totalPlayers: playerAmount,
          randomAnswerCard: Random(seed),
          randomQuestionCard: Random(seed + 1),
          questionList: questionList,
          answerList: answerList,
        );

        // If this is the 1st player starts as a master
        return (playerNumber == 1)
            ? Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => MasterGamePage(rand)))
            : Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => GamePage(rand)));
      }
    });
  }

  /// Set all text fields of the page as "Cojion", to infor the user he inserted the data in a wrong format
  void cojion() {
    seedController.text = 'Cojion';
    playerAmountController.text = 'Cojion';
    playerNumberController.text = 'Cojion';
  }
}