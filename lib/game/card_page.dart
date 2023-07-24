import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:flutter/material.dart';

class CardPage extends StatefulWidget {
  final CasualityManager random;

  const CardPage(this.random, {super.key});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                buildCompleteCard(),
              ],
            ),
          ),
        ),
      ));

  Widget buildCompleteCard() => CardAH(
        onClicked: () => null,
        text: widget.random.question,
        isClickable: false,
        answersList: CasualityManager.selectedCards,
      );
}
