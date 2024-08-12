import 'package:cards_against_humanity/pages/components/appbar.dart';
import 'package:flutter/material.dart';

class EasterEgg extends StatelessWidget {
  final int randomNumber;

  const EasterEgg(this.randomNumber, {super.key});

  @override
  Widget build(BuildContext context) => PopScope(
        canPop: true,
        child: Scaffold(
          appBar: const CustomAppBar(),
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.asset('assets/eastereggs/104_$randomNumber.jpeg'),
            ),
          ),
        ),
      );
}
