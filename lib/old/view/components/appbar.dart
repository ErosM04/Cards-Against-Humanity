import 'package:cards_against_humanity/constants.dart';
import 'package:flutter/material.dart';

/// Customized [AppBar] for Cards Against Humanity
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  /// The leading icon, if null uses the defult arrow back.
  final Widget? leading;

  /// The score of the player, if this value is > -1 and ``[maxPoints]`` is >= to this value, the score is showed
  /// in the format: score/playedRounds.
  final int score;

  /// The maximum points the player could have obtained, which is also the amount of raound played, excluding those played
  /// as the master. If ``[maxPoints]`` is > -1 and this value is >= to that value, the score is showed in the format:
  /// score/playedRounds.
  final int maxPoints;

  const CustomAppBar({
    super.key,
    this.leading,
    this.score = -1,
    this.maxPoints = -1,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  State<StatefulWidget> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) => AppBar(
        centerTitle: true,
        leading: widget.leading,
        titleSpacing: 0,
        title: Text(
          appName,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: (widget.score > -1 && widget.maxPoints >= widget.score)
            ? [
                SizedBox(
                  width: 65,
                  child: IconButton(
                    padding: const EdgeInsets.all(0),
                    icon: Text(
                      '${widget.score}/${widget.maxPoints}',
                      style: TextStyle(
                          fontSize: 17,
                          color: Theme.of(context).colorScheme.secondary),
                    ),
                    onPressed: () {},
                  ),
                )
              ]
            : [Container()],
      );
}
