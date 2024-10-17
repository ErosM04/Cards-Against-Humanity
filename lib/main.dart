import 'package:cards_against_humanity/old/bloc/bloc/start_bloc.dart';
import 'package:cards_against_humanity/old/bloc/card_bloc.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/load/presentation/pages/start_page.dart';
import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const CardsAgainstHumanity());

/// Not so politically correct
class CardsAgainstHumanity extends StatelessWidget {
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => CardBloc()),
          BlocProvider(create: (context) => StartBloc())
        ],
        child: MaterialApp(
          title: appName,
          theme: appTheme,
          home: const StartPage(),
          debugShowCheckedModeBanner: false,
        ),
      );
}
