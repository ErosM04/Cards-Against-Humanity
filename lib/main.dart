import 'package:flutter/material.dart';

void main() {
  runApp(const CardsAgainstHumanity());
}

class CardsAgainstHumanity extends StatelessWidget {
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cards Against Humanity',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const StartPage(title: 'Cards Against Humanity'),
    );
  }
}

class StartPage extends StatefulWidget {
  const StartPage({super.key, required this.title});

  final String title;

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Text(widget.title),
        ),
        body: Center(
          child: Text('ciao'),
        ),
      );
}
