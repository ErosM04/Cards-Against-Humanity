import 'package:cards_against_humanity/pages/start_page.dart';
import 'package:cards_against_humanity/theme/theme.dart';
import 'package:flutter/material.dart';

void main() => runApp(const CardsAgainstHumanity());

/// Not so politically correct
class CardsAgainstHumanity extends StatelessWidget {
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Cards Against Humanity',
        theme: appTheme,
        home: const StartPage(),
      );
}
