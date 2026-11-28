import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/load/presentation/page/start_page.dart';
import 'package:cards_against_humanity/core/theme/theme.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Returns `true` when [logicalSize] represents a narrow/tall phone that stays locked to portrait.
bool shouldLockPortrait(Size logicalSize) {
  if (logicalSize.isEmpty) return false;
  final aspectRatio = logicalSize.longestSide / logicalSize.shortestSide;
  return logicalSize.shortestSide < 600 && aspectRatio > 1.65;
}

/// Applies portrait lock for narrow/tall phones while letting foldables and tablets rotate.
Future<void> syncOrientationPolicy(Size logicalSize) =>
    SystemChrome.setPreferredOrientations(
      shouldLockPortrait(logicalSize)
          ? const [DeviceOrientation.portraitUp]
          : DeviceOrientation.values,
    );

/// Initializes dependencies and runs the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
  if (view != null && !view.physicalSize.isEmpty) {
    await syncOrientationPolicy(view.physicalSize / view.devicePixelRatio);
  }
  runApp(const CardsAgainstHumanity());
}

/// Android app per giocare alla versione italiana di Cards Against Humanity
class CardsAgainstHumanity extends StatefulWidget {
  const CardsAgainstHumanity({super.key});

  @override
  State<CardsAgainstHumanity> createState() => _CardsAgainstHumanityState();
}

class _CardsAgainstHumanityState extends State<CardsAgainstHumanity>
    with WidgetsBindingObserver {
  bool? _lastLockedPortrait;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncFromCurrentView();
  }

  @override
  void didChangeMetrics() => _syncFromCurrentView();

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _syncFromCurrentView() {
    final view = WidgetsBinding.instance.platformDispatcher.views.firstOrNull;
    if (view == null || view.physicalSize.isEmpty) return;
    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final lockPortrait = shouldLockPortrait(logicalSize);
    if (_lastLockedPortrait == lockPortrait) return;
    _lastLockedPortrait = lockPortrait;
    syncOrientationPolicy(logicalSize);
  }

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
          home: const StartPage(
            checkForUpdate: true,
            showExplicitContentWarning: true,
          ),
          debugShowCheckedModeBanner: false,
        ),
      );
}
