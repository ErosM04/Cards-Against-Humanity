import 'package:flutter/material.dart';
import 'package:info_popup/info_popup.dart';

/// Displays an ⓘ icon which can be clicked to show a popup box containg some text.
class GameInfo extends StatelessWidget {
  /// The text to display inside the popup box, displayed when the object is clicked.
  final String infoText;

  const GameInfo({super.key, required this.infoText});

  @override
  Widget build(BuildContext context) => InfoPopupWidget(
        contentTitle: infoText,
        contentTheme: const InfoPopupContentTheme(
          infoContainerBackgroundColor: Colors.black,
          infoTextStyle: TextStyle(color: Colors.white),
          contentPadding: EdgeInsets.all(12),
          contentBorderRadius: BorderRadius.all(Radius.circular(20)),
          infoTextAlign: TextAlign.center,
        ),
        child: Icon(
          Icons.info_outline_rounded,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
}
