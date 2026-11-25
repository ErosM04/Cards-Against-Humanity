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
            body: SingleChildScrollView(
              child: Center(
                child: Column(children: [
                  const SizedBox(height: 30),
                  CardAHW(
                    text: gameBloc.currentQuestion?.text ?? '',
                    isClickable: false,
                    isMainCard: true,
                  ),
                  const SizedBox(height: 50),
                  (answerCardList.isEmpty)
                      ? _buildCardInputWidgets(gameBloc)
                      : _buildCardsListWidgets(),
                ]),
              ),
            ),
          );
        },
      );

  /// Read the data from the textfield, converts it into a list of numbers and then use these ids to get the answers.
  void _getAnswerCards(GameBloc gameBloc) {
    String str = textController.text
        .replaceAll(' ', '')
        .replaceAll(',', '')
        .replaceAll('-', '');

    final expectedCount =
        gameBloc.cardsToClick * (gameBloc.gameData.totalPlayers - 1);

    if (str.contains('.') && (str.split('.').length == expectedCount)) {
      final splitArr = str.split('.');

      // If data inserted aren't numbers the function stops
      for (var element in splitArr) {
        if (int.tryParse(element) == null) return;
      }

      final cardIds = List<int>.generate(
          splitArr.length, (index) => int.parse(splitArr[index]));

      // Notify BLoC of requested answer card IDs
      context.read<GameBloc>().add(AnswerCardsRequested(ids: cardIds));
    }
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
  Widget _buildCardInputWidgets(GameBloc gameBloc) => Column(
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
            child: CustomTextField(controller: textController),
          ),
          _buildButton(
            text: 'Mostra carte',
            onPressed: () => _getAnswerCards(gameBloc),
          ),
        ],
      );

  /// Builds the set of widgets used to show the differents answer cards (one per player), with each card containg
  /// the answer/s to the question card.
  Widget _buildCardsListWidgets() => Column(
        children: [
          _buildCardCarousel(answerCardList),
          _buildButton(
              text: 'Prossimo round', onPressed: () => _goToNewRound()),
        ],
      );

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

  /// Takes a list of answers and build a horizontal list of [CardAHW] containg the different answers of the different
  /// players (shuffled).
  Widget _buildCardCarousel(List<String> list) => SizedBox(
        height: 220,
        child: ListView.builder(
            itemCount: list.length,
            shrinkWrap: true,
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
