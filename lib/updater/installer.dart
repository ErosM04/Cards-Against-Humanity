import 'dart:io';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:cards_against_humanity/updater/view/dialog_builders/error_dialog_builder.dart';
import 'package:cards_against_humanity/updater/view/dialog_contents/error_dialog_content.dart';
import 'package:flutter/material.dart';
import 'package:cards_against_humanity/updater/updater.dart';
import 'package:open_filex/open_filex.dart';
import 'package:file_picker/file_picker.dart';

/// This class is used by the ``[Updater]`` object in order to install the downloaded apk file.
class Installer {
  /// Context used to call both the ``[CustomSnackBar]`` and the ``[CustomDialog]``.
  final BuildContext context;

  const Installer(this.context);

  Future<void> installUpdate(String path) async {
    OpenFilex.open(path).then(
      (result) => (result.type != ResultType.done)
          ? ErrorDialogBuilder(
                  context: context,
                  content: ErrorDialogContent(
                      errorType: result.message, path: _getShortPath(path)),
                  denyButtonAction: () => _callSnackBar(message: ':('),
                  confirmButtonAction: () => _manuallySelectAndInstallUpdate())
              .invokeDialog()
          : null,
    );
  }

  Future<void> _manuallySelectAndInstallUpdate() async {
    try {
      FilePickerResult? pickResult = await FilePicker.platform.pickFiles();

      if (pickResult != null && pickResult.files.single.path != null) {
        File file = File(pickResult.files.single.path!);
        var installResult = await OpenFilex.open(file.path);
        if (installResult.type != ResultType.done) {
          throw Exception();
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      _callSnackBar(
          message: 'An error occurred while manually installing the update :(');
    }
  }

  String _getShortPath(String path, {String splitCarachter = '/'}) =>
      '${path.split(splitCarachter)[path.split(splitCarachter).length - 2]}/${path.split(splitCarachter).last}';

  /// Function used to simplify the invocation of the ``[SnackBarMessage]``.
  void _callSnackBar(
          {required String message,
          int durationInSec = 2,
          int? durationInMil}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build(context));
}
