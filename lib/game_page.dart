import 'dart:math';

import 'package:cards_against_humanity/card.dart';
import 'package:cards_against_humanity/logic/logic.dart';
import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  final int seed;
  final int playerNumber;
  final CasualityManager random;
  final List<List> questionList;

  const GamePage({
    super.key,
    required this.seed,
    required this.playerNumber,
    required this.random,
    required this.questionList,
  });

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  void initState() {
    super.initState();
    print(widget.questionList);
  }

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Cards Against Humanity',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            automaticallyImplyLeading: false,
          ),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                CardAH(
                  onClicked: () => null,
                  text: widget.questionList[Random(widget.seed)
                      .nextInt(widget.questionList.length)][0],
                  isClickable: false,
                ),
                const SizedBox(height: 100),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Text(
                        'La tua mano:',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                      itemCount: 10,
                      shrinkWrap: true,
                      controller: ScrollController(),
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) => CardAH(
                          onClicked: () => print('ayoo'),
                          text:
                              '$index - Correre nudi in un centro commerciale pisciando e cagando nudi e pisciando e cagando nudi e cagando nudi')),
                ),
              ],
            ),
          ),
        ),
      );
}
