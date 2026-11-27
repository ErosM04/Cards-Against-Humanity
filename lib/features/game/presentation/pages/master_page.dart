import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/widgets/textfield.dart';
import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/game_page.dart';
import 'package:cards_against_humanity/features/load/presentation/page/start_page.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:cards_against_humanity/core/widgets/appbar.dart';
import 'package:cards_against_humanity/core/widgets/button.dart';
import 'package:cards_against_humanity/core/widgets/card.dart';
import 'package:cards_against_humanity/core/widgets/info.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Page of the player which has to insert the ids of the cards selected by the other players.
class MasterGamePage extends StatefulWidget {
  const MasterGamePage({super.key});

  @override
  State<MasterGamePage> createState() => _MasterGamePageState();
}

class _MasterGamePageState extends State<MasterGamePage> {
  /// The list of answer cards that will be inserted by the player.
  List<String> answerCardList = [];

  /// The controller of the [TextField] where the players inserts the ids of the answer cards.
  final textController = TextEditingController();

  /// Form key used to validate the entered card IDs.
  final _formKey = GlobalKey<FormState>();

  /// Async error message returned by [GameBloc] when IDs fail eligibility checks.
  String? _inputError;

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is AnswerCardsLoaded) {
            final gameBloc = context.read<GameBloc>();
            final answers = state.answers;
            final expectedCount =
                gameBloc.cardsToClick * (gameBloc.gameData.totalPlayers - 1);

            if (answers.length == expectedCount) {
              final answerTexts = List<String>.generate(
                answers.length,
                (index) => answers.getCardAt(index).text,
              );

              if (gameBloc.cardsToClick == 1) {
                answerTexts.shuffle();
                setState(() => answerCardList = answerTexts);
              } else {
                List<List<String>> bigList = [];
                for (var i = 0; i < answerTexts.length; i += 2) {
                  bigList.add([answerTexts[i], answerTexts[i + 1]]);
                }
                bigList.shuffle();

                List<String> resultList = [];
                for (List<String> list in bigList) {
                  resultList.add('${list[0]}\n\n${list[1]}');
                }
                setState(() => answerCardList = resultList);
              }
            }
          } else if (state is LoadFailure && state.message.isNotEmpty) {
            setState(() => _inputError = state.message);
          }
        },
        builder: (context, state) {
          final gameBloc = context.read<GameBloc>();
          return Scaffold(
            appBar: CustomAppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => const StartPage())),
              ),
              score: gameBloc.gameData.score,
              maxPoints: gameBloc.gameData.playerRounds,
            ),
            body: LayoutBuilder(
              builder: (context, constraints) {
                final screenHeight = MediaQuery.sizeOf(context).height;
                final edgeSpacing = (screenHeight * 0.05).clamp(24.0, 72.0);
                final isInputPhase = answerCardList.isEmpty;

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(
                        // Compensate CardAHW's 14px outer margin so top/bottom edge gaps match.
                        top: (edgeSpacing - 14).clamp(6.0, 72.0),
                        bottom: edgeSpacing,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CardAHW(
                                text: gameBloc.currentQuestion?.text ?? '',
                                isClickable: false,
                                isMainCard: true,
                              ),
                              SizedBox(
                                // Compensate CardAHW's 14px bottom margin so gap matches edgeSpacing.
                                height: (edgeSpacing - 14).clamp(10.0, 72.0),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: isInputPhase
                                    ? _buildCardInputWidgets(gameBloc)
                                    : _buildCardCarousel(answerCardList),
                              ),
                            ],
                          ),
                          CustomButton(
                            text: isInputPhase
                                ? 'Mostra carte'
                                : 'Prossimo round',
                            onPressed: isInputPhase
                                ? () => _getAnswerCards(gameBloc)
                                : _goToNewRound,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      );

  static final RegExp _allowedCharsPattern = RegExp(r'^[0-9.,-]+$');
  static final RegExp _separatorPattern = RegExp(r'[.,-]');

  /// Validates [raw] card ID input syntax and expected count, returning an error message or `null`.
  static String? validateCardIdsInput(String raw, int expectedCount) {
    final cleaned = raw.replaceAll(' ', '');
    if (!_allowedCharsPattern.hasMatch(cleaned)) {
      return 'Caratteri non validi: usa solo numeri e ".", "," o "-"';
    }

    final parts = cleaned.split(_separatorPattern);
    if (parts.any((part) => part.isEmpty)) {
      return 'Formato non valido: usa numeri separati da ".", "," o "-"';
    }
    if (parts.length != expectedCount) {
      return 'Inserisci $expectedCount numeri separati da ".", "," o "-"';
    }

    for (final part in parts) {
      if (int.tryParse(part) == null) {
        return 'Uno o più numeri non sono validi';
      }
    }
    return null;
  }

  /// Validates the input field, parses card IDs, and dispatches [AnswerCardsRequested].
  void _getAnswerCards(GameBloc gameBloc) {
    if (_inputError != null) {
      setState(() => _inputError = null);
    }
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final parts =
        textController.text.replaceAll(' ', '').split(_separatorPattern);
    final cardIds =
        List<int>.generate(parts.length, (index) => int.parse(parts[index]));
    context.read<GameBloc>().add(AnswerCardsRequested(ids: cardIds));
  }

  /// Goes to the next round.
  void _goToNewRound() {
    final gameBloc = context.read<GameBloc>();
    final nextRound = gameBloc.gameData.totalRounds + 1;
    final isNextMaster = gameBloc.gameData.isMasterRound(nextRound);

    gameBloc.add(StartRound(isMaster: isNextMaster));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: serviceLocator<GameBloc>(),
          child: isNextMaster ? const MasterGamePage() : const GamePage(),
        ),
      ),
    );
  }

  /// Builds the set of widgets used to take the cards id as input, to later save them into ``[answerCardList]``.
  Widget _buildCardInputWidgets(GameBloc gameBloc) {
    final expectedCount =
        gameBloc.cardsToClick * (gameBloc.gameData.totalPlayers - 1);
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildSubTitle('Inserisci i numeri delle carte:', fontSize: 22),
          _buildSubTitle(
            'es: 11.22.104',
            fontSize: 18,
            verticalPadding: 2,
            info: cardsIdInput,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomTextField(
              controller: textController,
              errorText: _inputError,
              onChanged: (_) {
                if (_inputError != null) {
                  setState(() => _inputError = null);
                }
              },
              validator: (value) =>
                  validateCardIdsInput(value!, expectedCount),
            ),
          ),
        ],
      ),
    );
  }

  /// Takes a list of answers and build a horizontal list of [CardAHW] containg the different answers of the different
  /// players (shuffled).
  Widget _buildCardCarousel(List<String> list) => SizedBox(
        height: 220,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
            clipBehavior: Clip.none,
            controller: ScrollController(),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) => CardAHW(
                  text: list[index],
                  isClickable: false,
                )),
      );

  /// Builds a customizable subtitle
  Widget _buildSubTitle(
    String text, {
    double fontSize = 24,
    double horizontalPadding = 20,
    double verticalPadding = 0,
    String? info,
  }) =>
      Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: verticalPadding,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            (info != null && info.isNotEmpty)
                ? GameInfo(infoText: info)
                : Container(),
          ],
        ),
      );
}
