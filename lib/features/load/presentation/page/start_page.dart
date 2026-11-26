import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/entities/data/answer_list.dart';
import 'package:cards_against_humanity/core/entities/data/question_list.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:cards_against_humanity/core/widgets/appbar.dart';
import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:cards_against_humanity/core/widgets/info.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/game_page.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/master_page.dart';
import 'package:cards_against_humanity/core/widgets/textfield.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/update_listener.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Initial screen for configuring match parameters and launching a game.
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

  /// Uses [route] to invoke a [MasterGamePage].
  static void routeToMasterPage({required BuildContext context}) => route(
        context: context,
        page: BlocProvider.value(
          value: serviceLocator<GameBloc>(),
          child: const MasterGamePage(),
        ),
      );

  /// Uses [route] to invoke a [GamePage].
  static void routeToGamePage({required BuildContext context}) => route(
        context: context,
        page: BlocProvider.value(
          value: serviceLocator<GameBloc>(),
          child: const GamePage(),
        ),
      );

  @override
  void initState() {
    context.read<UpdateBloc>().add(const UpdateCacheClearRequested());

    // Checks if a new version exists and asks for download consent.
    // The 2 seconds delay avoids showing dialogs before the initial frame settles.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<UpdateBloc>().add(const UpdateCheckRequested());
      }
    });

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
  Widget build(BuildContext context) => UpdateListener(
        child: Scaffold(
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
                    CustomTextField(
                      controller: seedController,
                      validator: (value) => _tryParseText(value!) == null
                          ? 'Cazzo hai scritto?!'
                          : null,
                    ),
                    const SizedBox(height: 100),

                    // Total players
                    _buildSubTitle(
                      subTitle: 'Totale giocatori',
                      infoText: totalPlayersInfo,
                    ),
                    CustomTextField(
                      controller: playerAmountController,
                      validator: (value) {
                        final amount = _tryParseText(value!);
                        if (amount == null) return 'Cazzo hai scritto?!';
                        if (amount < minPlayers) {
                          return 'Minimo $minPlayers giocatori!';
                        }
                        if (amount > maxPlayers) {
                          return 'Massimo $maxPlayers giocatori!';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 100),

                    // Player number
                    _buildSubTitle(
                      subTitle: 'Numero giocatore',
                      infoText: playerNumberInfo,
                    ),
                    CustomTextField(
                      controller: playerNumberController,
                      validator: (value) {
                        final number = _tryParseText(value!);
                        if (number == null) return 'Cazzo hai scritto?!';
                        final amount =
                            _tryParseText(playerAmountController.text);
                        final hasValidAmount = amount != null &&
                            amount >= minPlayers &&
                            amount <= maxPlayers;
                        if (number <= 0 ||
                            (hasValidAmount && number > amount)) {
                          return 'Il valore $number è fuori dal range!';
                        }
                        return null;
                      },
                    ),
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

  /// Validates the form fields and redirects to [MasterGamePage] or [GamePage].
  void _startGame() {
    if (!formKey.currentState!.validate()) return;

    final seed = _tryParseText(seedController.text)!;
    final playerAmount = _tryParseText(playerAmountController.text)!;
    final playerNumber = _tryParseText(playerNumberController.text)!;

    // Initialize game session dependencies for BLoC
    initGameDependencies(
      seed: seed,
      playerNumber: playerNumber,
      totalPlayers: playerAmount,
      questionList: questionList,
      answerList: answerList,
    );

    final isMaster = (playerNumber == 1);
    final gameBloc = serviceLocator<GameBloc>();
    gameBloc.add(StartRound(isMaster: isMaster));

    // If this is the 1st player starts as a master, otherwise start as normal player
    if (isMaster) {
      routeToMasterPage(context: context);
    } else {
      routeToGamePage(context: context);
    }
  }

  /// Parses integer input after stripping spaces, dots, and dashes.
  int? _tryParseText(String text) => int.tryParse(
        text.replaceAll(' ', '').replaceAll('.', '').replaceAll('-', ''),
      );
}
