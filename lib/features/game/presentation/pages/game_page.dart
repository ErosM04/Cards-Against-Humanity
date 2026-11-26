import 'package:cards_against_humanity/features/game/presentation/bloc/game_bloc.dart';
import 'package:cards_against_humanity/features/game/presentation/pages/card_page.dart';
import 'package:cards_against_humanity/features/load/presentation/page/start_page.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:cards_against_humanity/core/widgets/appbar.dart';
import 'package:cards_against_humanity/core/widgets/card.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// The normal Game page, where the player has to choose the funniest answer/s card/s to complete the
/// question card.
class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) => BlocConsumer<GameBloc, GameState>(
        listener: (context, state) {
          if (state is FirstCardCliked || state is SecondCardCliked) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: serviceLocator<GameBloc>(),
                  child: const CardPage(),
                ),
              ),
            );
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
                  const SizedBox(height: 100),
                  _buildSubTitle('La tua mano:'),
                  const SizedBox(height: 20),
                  _buildCardCarousel(gameBloc),
                ]),
              ),
            ),
          );
        },
      );

  /// Builds the subtitles
  Widget _buildSubTitle(
    String text, {
    double fontSize = 24,
    double horizontalPadding = 20,
    double verticalPadding = 0,
  }) {
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

  /// Takes the player hand and builds a horizontal list of cards using the [CardAHW] widget.
  Widget _buildCardCarousel(GameBloc gameBloc) {
    final hand = gameBloc.gameData.handList;
    return SizedBox(
      height: 220,
      child: ListView.builder(
        itemCount: hand.length,
        shrinkWrap: true,
        clipBehavior: Clip.none,
        controller: ScrollController(),
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final card = hand.getCardAt(index);
          final cardText = '${card.id} - ${card.text}';
          final isSelected = gameBloc.selectedCards.contains(card);
          return CardAHW(
            text: cardText,
            isSelected: isSelected,
            onClicked: () {
              context.read<GameBloc>().add(CardClicked(card));
            },
          );
        },
      ),
    );
  }
}
