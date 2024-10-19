import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/gamelogic/logic.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/old/view/components/appbar.dart';
import 'package:cards_against_humanity/old/view/components/button.dart';
import 'package:cards_against_humanity/old/view/components/info.dart';
import 'package:cards_against_humanity/old/view/pages/easteregg.dart';
import 'package:cards_against_humanity/old/view/pages/game_page.dart';
import 'package:cards_against_humanity/old/view/pages/master_page.dart';
import 'package:cards_against_humanity/features/load/presentation/widgets/textfield.dart';
import 'package:cards_against_humanity/old/updater/updater.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPage extends StatefulWidget {
  /// The object used to load data from the csv files in the assets.
  final CsvReader csvReader = const CsvReader();

  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  /// The controller of the [TextField] of the seed.
  final seedController = TextEditingController();

  /// The controller of the [TextField] of the amount of players.
  final playerAmountController = TextEditingController();

  /// The controller of the [TextField] of the specific number of the player.
  final playerNumberController = TextEditingController();

  /// List of the questions loaded from the csv.
  late List<List<String>> questionList;

  /// List of the answers wloaded from the csv.
  late List<String> answerList;

  /// The key used to validate the [TextFormField] in the [Form].
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    // Checks if a new version exists and ask for download consent.
    // The 2 seconds delay is to avoid errors (trust me).
    var updater = Updater(context);

    Future.delayed(
      const Duration(seconds: 2),
      () => updater.updateToNewVersion(),
    );

    // Load data from csv
    context.read<LoadBloc>().add(LoadStart());

    super.initState();
  }

  @override
  void dispose() {
    seedController.dispose();
    playerAmountController.dispose();
    playerNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const CustomAppBar(),
        body: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Seed
                    _buildSubTitle(
                        subTitle: 'Codice partita', infoText: seedInfo),
                    Row(
                      children: [
                        Text(
                          'Inserire un numero di almeno 10 cifre',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    CustomTextField(controller: seedController),
                    const SizedBox(height: 100),
                    // Total players
                    _buildSubTitle(
                        subTitle: 'Totale giocatori',
                        infoText: totalPlayersInfo),
                    CustomTextField(controller: playerAmountController),
                    const SizedBox(height: 100),
                    // Player number
                    _buildSubTitle(
                        subTitle: 'Numero giocatore',
                        infoText: playerNumberInfo),
                    CustomTextField(controller: playerNumberController),
                    const SizedBox(height: 50),
                    // Link guide
                    GestureDetector(
                      onTap: () => launchUrl(Uri.parse(
                          'https://github.com/ErosM04/Cards-Against-Humanity')),
                      child: const Text(
                        'Clicca qui per la guida!',
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.blue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Gioca button
                    BlocListener<LoadBloc, LoadState>(
                      listener: (context, state) {
                        if (state is LoadCompleted) {
                          questionList = state.questions;
                          answerList = state.answers;
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: CustomButton(
                          text: 'Gioca',
                          onPressed: () => _startGame(),
                          horizontalInternalPadding: 80,
                          verticalInternalPadding: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  /// Creates a row with a subtitle on the left and an ``[GameInfo]`` on the right.
  ///
  /// #### Parameters
  /// - ``String subTitle`` : the text of the subtitle, at the and ":" will be added.
  /// - ``String infoText`` : the text to display on the popup box when the ``[GameInfo]`` is clicked.
  Widget _buildSubTitle({required String subTitle, required String infoText}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$subTitle:',
            textAlign: TextAlign.start,
            style: const TextStyle(fontSize: 20),
          ),
          GameInfo(infoText: infoText),
        ],
      );

  /// Read the data from the [TextField] and tries to convert them into numbers. If these data are in the correct format
  /// proceeds to redirect the user either to the **Game** or o the **Master** page.
  void _startGame() {
    if (!formKey.currentState!.validate()) return;

    // Cheks if the data in the textfields are empty
    if (seedController.text.isEmpty ||
        playerAmountController.text.isEmpty ||
        playerNumberController.text.isEmpty) {
      _cojion();
      return;
    }

    // tries converting to int
    int? seed = _tryParseInput(seedController);
    int? playerAmount = _tryParseInput(playerAmountController);
    int? playerNumber = _tryParseInput(playerNumberController);

    // Checks if the data are in the correct format
    if (seed == null ||
        playerAmount == null ||
        playerNumber == null ||
        playerNumber <= 0 ||
        playerNumber > playerAmount ||
        playerAmount < 3 ||
        playerAmount > 20) {
      _cojion();
      return;
    }

    if (seed == 104 && mounted) {
      // Easter egg
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (context) => const EasterEgg()));
    } else {
      // Normal execution
      CasualityManager rand = CasualityManager(
        seed: seed,
        playerNumber: playerNumber,
        totalPlayers: playerAmount,
        questionList: questionList,
        answerList: answerList,
      );

      // If this is the 1st player starts as a master, otherwise start as normal player
      if (playerNumber == 1) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => MasterGamePage(rand)));
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => GamePage(rand)));
      }
    }
  }

  /// Tryes parsing the string inside the ``[TextField]`` associated with the given ``[controller]`` into an [int].
  /// If something goes wrong a null is returned.
  int? _tryParseInput(TextEditingController controller) =>
      int.tryParse(controller.text
          .replaceAll(' ', '')
          .replaceAll('.', '')
          .replaceAll('-', ''));

  /// Set all text fields of the page as "Cojion", to infor the user he inserted the data in a wrong format.
  void _cojion() {
    seedController.text = 'Cojion';
    playerAmountController.text = 'Cojion';
    playerNumberController.text = 'Cojion';
  }
}
