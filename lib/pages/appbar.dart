import 'package:flutter/material.dart';

/// Customized [AppBar] for Cards Against Humanity
class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final List<Widget>? actions;
  final Widget? leading;

  const CustomAppBar({
    super.key,
    this.actions,
    this.leading,
  }) : preferredSize = const Size.fromHeight(kToolbarHeight);

  @override
  final Size preferredSize;

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) => AppBar(
        centerTitle: true,
        leading: widget.leading,
        titleSpacing: 0,
        title: Text(
          'Cards Against Humanity',
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        actions: widget.actions,
      );
}
