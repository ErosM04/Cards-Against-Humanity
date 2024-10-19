import 'package:cards_against_humanity/features/load/data/datasource/local_datasource.dart';
import 'package:cards_against_humanity/features/load/data/provider/csv_reader.dart';
import 'package:cards_against_humanity/features/load/data/repository/load_repository_impl.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/load/presentation/pages/start_page.dart';
import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(const CardsAgainstHumanity());

/// Not so politically correct
class CardsAgainstHumanity extends StatelessWidget {
  final csvReader = const CsvReader();
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => LoadBloc(
              loadQuestions: LoadQuestions(
                loadRepository: LoadRepositoryImpl(
                  localDataSource: LoadLocalDataSourceImpl(
                    csvReader: csvReader,
                  ),
                ),
              ),
              loadAnswers: LoadAnswers(
                loadRepository: LoadRepositoryImpl(
                  localDataSource:
                      LoadLocalDataSourceImpl(csvReader: csvReader),
                ),
              ),
            ),
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
