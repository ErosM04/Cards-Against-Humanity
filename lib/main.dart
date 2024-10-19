import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/load/presentation/pages/start_page.dart';
import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() async {
  await initDependencies();
  runApp(const CardsAgainstHumanity());
}

/// Not so politically correct
class CardsAgainstHumanity extends StatelessWidget {
  final csvReader = const CsvReader();
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<LoadBloc>(),
          ),
        ],
        child: MaterialApp(
          title: appName,
          theme: appTheme,
          home: const StartPage(),
          debugShowCheckedModeBanner: false,
        ),
      );
}
