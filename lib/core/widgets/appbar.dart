import 'package:cards_against_humanity/constants.dart';
import 'package:material_ui/material_ui.dart';

/// Customized [AppBar] for Cards Against Humanity.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// The leading icon, if null uses the default arrow back.
  final Widget? leading;

  /// The score of the player. If > -1 and [maxPoints] >= [score], score is shown as score/maxPoints.
  final int score;

  /// The maximum points the player could have obtained (played rounds excluding Master turns).
  final int maxPoints;

  const CustomAppBar({
    super.key,
    this.leading,
    this.score = -1,
    this.maxPoints = -1,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(
        centerTitle: true,
        leading: leading,
        titleSpacing: 0,
        title: Text(
          appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: (score > -1 && maxPoints >= score)
            ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '$score/$maxPoints',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      );
}
