import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/gamelogic/logic.dart';
import 'package:cards_against_humanity/features/load/domain/entities/answer_list.dart';
import 'package:cards_against_humanity/features/load/domain/entities/question_list.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/old/view/components/appbar.dart';
import 'package:cards_against_humanity/old/view/components/button.dart';
import 'package:cards_against_humanity/old/view/components/info.dart';
import 'package:cards_against_humanity/old/view/pages/easteregg.dart';
import 'package:cards_against_humanity/old/view/pages/game_page.dart';
import 'package:cards_against_humanity/old/view/pages/master_page.dart';
import 'package:cards_against_humanity/core/widgets/textfield.dart';
import 'package:cards_against_humanity/old/updater/updater.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  /// List of the questions loaded from the csv.
  late QuestionList questionList;

  /// List of the answers wloaded from the csv.
  late AnswerList answerList;

  /// The controller of the [TextField] of the seed.
  final seedController = TextEditingController();

  /// The controller of the [TextField] of the amount of players.
  final playerAmountController = TextEditingController();

  /// The controller of the [TextField] of the specific number of the player.
  final playerNumberController = TextEditingController();

  /// The key used to validate the [TextFormField] in the [Form].
  final formKey = GlobalKey<FormState>();

  /// Routes to a different [page] using `pushReplacement`.
  static void route({
    required BuildContext context,
    required Widget page,
  }) =>
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => page),
      );

  /// Uses [route] to invoke a [MasterGamePage] which takes [rand].
  static void routeToMasterPage(
          {required BuildContext context, required CasualityManager rand}) =>
      route(context: context, page: MasterGamePage(rand));

  /// Uses [route] to invoke a [GamePage] which takes [rand].
  static void routeToGamePage(
          {required BuildContext context, required CasualityManager rand}) =>
      route(context: context, page: GamePage(rand));

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
    context.read<LoadBloc>().add(LoadQuestionsStart());
    context.read<LoadBloc>().add(LoadAnswersStart());

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
                    // Tip
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
                      infoText: totalPlayersInfo,
                    ),
                    CustomTextField(controller: playerAmountController),
                    const SizedBox(height: 100),

                    // Player number
                    _buildSubTitle(
                      subTitle: 'Numero giocatore',
                      infoText: playerNumberInfo,
                    ),
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
                        if (state is LoadQuestionsCompleted) {
                          questionList = state.questions;
                        } else if (state is LoadAnswersCompleted) {
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
    // Checks if the content of the text fields is empty.
    if (!formKey.currentState!.validate()) return;

    // Tries to convert the input to int
    int? seed = _tryParseInput(seedController);
    int? playerAmount = _tryParseInput(playerAmountController);
    int? playerNumber = _tryParseInput(playerNumberController);

    // Checks if the data are in the correct format, otherwise displays an error message
    if (!_validateInputValues(
      seed: seed,
      playerAmount: playerAmount,
      playerNumber: playerNumber,
    )) return;

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
        routeToMasterPage(context: context, rand: rand);
      } else {
        routeToGamePage(context: context, rand: rand);
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

  /// Controls the values passed, which should be the input from the text fields, and if verifies there is any problem.
  /// For each problem the respective field's text is set to a message describes the error.
  ///
  /// Returns `true` there are no problems, or `flase` otherwise.
  bool _validateInputValues({
    required int? seed,
    required int? playerAmount,
    required int? playerNumber,
  }) {
    if (seed == null || playerAmount == null || playerNumber == null) {
      seedController.text = 'Cazzo hai scritto?!';
      playerAmountController.text = 'Cazzo hai scritto?!';
      playerNumberController.text = 'Cazzo hai scritto?!';
      return false;
    } else if (playerAmount < 3) {
      playerAmountController.text = 'Minimo $minPlayers giocatori!';
      return false;
    } else if (playerAmount > 20) {
      playerAmountController.text = 'Massimo $maxPlayers giocatori!';
      return false;
    } else if (playerNumber <= 0 || playerNumber > playerAmount) {
      playerNumberController.text =
          'Il valore $playerNumber è fuori dal range!';
      return false;
    }
    return true;
  }
}
