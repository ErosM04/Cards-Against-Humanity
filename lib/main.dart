import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/load/presentation/page/start_page.dart';
import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Initializes dependencies and runs the application.
void main() async {
  await initDependencies();
  runApp(const CardsAgainstHumanity());
}

/// Android app per giocare alla versione italiana di Cards Against Humanity
class CardsAgainstHumanity extends StatelessWidget {
  const CardsAgainstHumanity({super.key});

  @override
  Widget build(BuildContext context) => MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => serviceLocator<LoadBloc>(),
          ),
          BlocProvider(
            create: (context) => serviceLocator<UpdateBloc>(),
          ),
        ],
        child: MaterialApp(
          title: appName,
          theme: appTheme,
          home: const StartPage(checkForUpdate: true),
          debugShowCheckedModeBanner: false,
        ),
      );
}
