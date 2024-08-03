import 'package:flutter/material.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_contents/dialog_content.dart';

/// Overrides [DialogContent] to create a content to display inside an ``[ErrorDialogContent]``.
///
/// This widget creates a [Column] of widgets which:
/// - asks the user if he/she wants to manually install the update;
/// - informs the user about the error that occurred while installing the update file (e.g. ``'File not found'``);
/// - informs the user that he/she is about to be redirected to the file manager and that he/she has to pick a file
/// located at a specific path;
class ErrorDialogContent extends DialogContent {
  /// The error message (e.g. ``'File not found'``).
  final String errorType;

  /// The path of the file (filename and extension included).
  final String path;

  const ErrorDialogContent({
    super.key,
    required this.errorType,
    required this.path,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Vuoi installare manualmente l'aggiornamento?",
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const SizedBox(height: 5),
          const Text(
              "Durante l'installazione dell'aggiornamento si è verificato un errore:"),
          const SizedBox(height: 3),
          (isSafe(errorType))
              ? buildCustomText(errorType, color: Colors.red)
              : Container(),
          const SizedBox(height: 10),
          const Text(
              'Verrai ora rediretto al file manager per eseguire il file di aggiornamento che si trova in:'),
          const SizedBox(height: 5),
          (isSafe(path))
              ? buildCustomText(path, color: Colors.blue)
              : Container(),
          const SizedBox(height: 5),
          const Divider(),
        ],
      );
}
