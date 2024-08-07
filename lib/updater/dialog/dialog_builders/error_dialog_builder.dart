import 'package:flutter/material.dart';
import 'package:cards_against_humanity/updater/dialog/custom_dialog.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_builders/dialog_builder.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_contents/error_dialog_content.dart';

/// Extends ``[DialogBuilder]`` in order to create a [CustomDialog] suitable to infrom the user that something went
/// wrong while trying to install the downloaded updated ``.apk`` file.
///
/// The dialog ``[content]`` should be a ``[ErrorDialogContent]`` widget.
class ErrorDialogBuilder extends DialogBuilder {
  const ErrorDialogBuilder({
    required super.context,
    required super.content,
    required super.denyButtonAction,
    required super.confirmButtonAction,
    super.animate,
  });

  /// Ovverrides the main [buildDialog] method in order to create an installation error widget.
  /// The alert informs that while trying to install the downloaded updated ``.apk`` file somwthing went wrong
  /// and shows a red X image.
  @override
  CustomDialog buildDialog() => CustomDialog(
        image: Image.asset(
          'assets/dialog/error.png',
          scale: 9,
          color: Theme.of(context).colorScheme.tertiary,
        ),
        title: "Errore durante l'installazione dell'aggiornamento",
        denyButtonAction: denyButtonAction,
        confirmButtonAction: confirmButtonAction,
        child: content,
      );
}
