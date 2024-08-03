import 'dart:io';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_builders/error_dialog_builder.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_contents/error_dialog_content.dart';
import 'package:flutter/material.dart';
import 'package:cards_against_humanity/updater/updater.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cards_against_humanity/updater/dialog/custom_dialog.dart';

/// This class is used by the ``[Updater]`` object in order to install the downloaded apk file.
class Installer {
  /// Context used to call both the ``[SnackBarMessage]`` and the ``[CustomDialog]``.
  final BuildContext context;

  const Installer(this.context);

  Future<void> installUpdate(String path) async =>
      _requestInstallPackagesPermission(
          onGranted: () => OpenFile.open(path).then(
                (result) => (result.type != ResultType.done)
                    ? ErrorDialogBuilder(
                        context: context,
                        content: ErrorDialogContent(
                            errorType: result.message,
                            path: _getShortPath(path)),
                        denyButtonAction: () => _callSnackBar(message: ':('),
                        confirmButtonAction: () =>
                            _manuallySelectAndInstallUpdate()).invokeDialog()
                    : null,
              ),
          onDenied: () => _callSnackBar(
                message:
                    "Ma come no? Cattivo! Vatti a installare l'update nella cartella Download",
                durationInSec: 5,
              ));

  void _requestInstallPackagesPermission(
      {required Function onGranted, required Function onDenied}) async {
    var status = await Permission.requestInstallPackages.status;
    if (status.isGranted) {
      // Il permesso è già stato concesso
      onGranted();
    } else {
      // Richiedi il permesso
      if (await Permission.requestInstallPackages.request().isGranted) {
        // Il permesso è stato concesso
        onGranted();
      } else {
        // Il permesso è stato negato
        onDenied();
      }
    }
  }

  Future<void> _manuallySelectAndInstallUpdate() async {
    try {
      FilePickerResult? pickResult = await FilePicker.platform.pickFiles();

      if (pickResult != null && pickResult.files.single.path != null) {
        File file = File(pickResult.files.single.path!);
        var installResult = await OpenFile.open(file.path);
        if (installResult.type != ResultType.done) {
          throw Exception();
        }
      } else {
        throw Exception();
      }
    } catch (e) {
      _callSnackBar(
          message:
              "Si è verificato un errore durante l'installazione manuale dell'aggiornamento :(");
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
