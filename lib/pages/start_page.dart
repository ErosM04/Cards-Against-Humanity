import 'dart:math';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:cards_against_humanity/model/data_reader.dart';
import 'package:cards_against_humanity/pages/easteregg.dart';
import 'package:cards_against_humanity/pages/game_page.dart';
import 'package:cards_against_humanity/pages/master_page.dart';
import 'package:cards_against_humanity/textfield.dart';
import 'package:cards_against_humanity/updater/updater.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  late Updater updater;

  @override
  void initState() {
    super.initState();

    // Checks if a new version exists and ask for download consent.
    // The 2 seconds delay is to avoid errors (trust me).
    updater = Updater(context);
    Future.delayed(
      const Duration(seconds: 2),
      () => updater.updateToNewVersion(),
    );
  }

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
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: () => launchUrl(Uri.parse(
                      'https://github.com/ErosM04/Cards-Against-Humanity')),
                  child: const Text(
                    'Clicca qui per la guida!',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                const SizedBox(height: 50),
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

  /// Read the data from the textfields and tries to convert them into numbers. If these data are in the correct format proceeds to redirect the
  /// user either to the Game or o the Master page.
  void startGame() {
    // Cheks if the data in the textfields are empty
    if (seedController.text.isEmpty ||
        playerAmountController.text.isEmpty ||
        playerNumberController.text.isEmpty) {
      cojion();
      return;
    }

    // tries converting to int
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

    // Checks if the data are in the correct format
    if (seed == null ||
        playerAmount == null ||
        playerNumber == null ||
        playerNumber <= 0 ||
        playerNumber > playerAmount ||
        playerAmount < 2 ||
        playerAmount > 20) {
      cojion();
      return;
    }

    List<List<dynamic>> questionList = [];
    widget.csvReader.getQuestions().then((list) {
      questionList = list;
      return widget.csvReader.getAnswers();
    }).then((answerList) {
      if (seed == 104) {
        //Easter egg
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => EasterEgg(Random().nextInt(10))));
      } else {
        // Normal execution
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
