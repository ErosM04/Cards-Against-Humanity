import 'package:flutter/material.dart';

class EasterEgg extends StatelessWidget {
  final int randomNumber;

  const EasterEgg(this.randomNumber, {super.key});

  @override
  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            automaticallyImplyLeading: false,
            title: Text(
              'Cards Against Humanity',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
          body: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Center(
              child: Image.asset('assets/eastereggs/104_$randomNumber.jpeg'),
            ),
          ),
        ),
      );
}
