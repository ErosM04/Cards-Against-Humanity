import 'dart:io';
import 'package:cards_against_humanity/old/updater/permission.dart';
import 'package:cards_against_humanity/old/updater/snackbar.dart';
import 'package:cards_against_humanity/old/updater/dialog/dialog_builders/error_dialog_builder.dart';
import 'package:cards_against_humanity/old/updater/dialog/dialog_contents/error_dialog_content.dart';
import 'package:flutter/material.dart';
import 'package:cards_against_humanity/old/updater/updater.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_file_plus/open_file_plus.dart';
import 'package:cards_against_humanity/old/updater/dialog/custom_dialog.dart';

/// This class is used by the ``[Updater]`` object in order to install the downloaded apk file.
class Installer {
  /// Context used to call both the ``[SnackBarMessage]`` and the ``[CustomDialog]``.
  final BuildContext context;

  const Installer(this.context);

  /// Uses ``[_askForInstallationPermission]``  to check if the **"Package Installation"** permission has already been granted,
  /// otherwise asks for it.
  ///
  /// If the permission is granted takes the ``[path]`` of the update apk file and uses ``[OpenFile]`` to execute it (the system will
  /// then manage the update).
  /// And if something goes wrong invokes an ``[ErrorDialogBuilder]``, which asks the user if he/she wants to manually select the apk
  /// update in order to execute it; done by using ``[_manuallySelectAndInstallUpdate]``.
  ///
  /// If the permission is not granted, a [SnackBar] is used to offend the user.
  ///
  /// #### Parameters
  /// - ``String path`` : the path to the apk file in the device storage.
  void installUpdate(String path) async => _askForInstallationPermission(
        onGranted: () => OpenFile.open(path).then(
          (result) => (result.type != ResultType.done && context.mounted)
              // The package wasn't able to execute the file (probably wrong path)
              ? ErrorDialogBuilder(
                  context: context,
                  content: ErrorDialogContent(
                      errorType: result.message, path: _getShortPath(path)),
                  denyButtonAction: () => _callSnackBar(message: ':('),
                  confirmButtonAction: () =>
                      _manuallySelectAndInstallUpdate()).invokeDialog()
              // The update executed
              : null,
        ),
        onDenied: () => _callSnackBar(
          message:
              "Ma come no? Cattivo! Vatti a installare l'update nella cartella Download",
          durationInSec: 5,
        ),
      );

  /// Uses the ``[PermissionManager]`` object to check if the **"Package Installation"** permission has already been granted,
  /// otherwise asks for it.
  ///
  /// If the permission has already been granted executes ``[onGranted]``. Otherwise informs the user that he needs the permission
  /// and then asks for it. If it's granted  executes ``[onGranted]``, otherwise  executes ``[onDenied]``.
  ///
  /// #### Parameters
  /// - ``Function onGranted`` : the function to execute if the permission is granted.
  /// - ``Function onDenied`` : the function to execute if the permission isn't granted.
  void _askForInstallationPermission({
    required Function onGranted,
    required Function onDenied,
  }) async {
    if (await PermissionManager.checkInstallPackages()) {
      onGranted();
    } else {
      _callSnackBar(
        message:
            "Ti verrà ora chiesto di dare il permesso per installare il pacchetto di aggiornamento",
        durationInSec: 5,
      );
      Future.delayed(
        const Duration(seconds: 5),
        () => PermissionManager.requestInstallPackages(
            onGranted: onGranted, onDenied: onDenied),
      );
    }
  }

  /// Uses ``[FilePicker]`` to open a **File Manager**. The file picked by the user will than be executed.
  /// The file type is restricted to **apk**.
  void _manuallySelectAndInstallUpdate() async {
    try {
      FilePickerResult? pickResult = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['apk']);

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
              "Si è verificato un errore durante l'installazione manuale dell'aggiornamento :(",
          durationInSec: 5);
    }
  }

  /// Takes a ``[path]`` and splits that based on ``[splitCharacter]``, then returns a path containg only the last 2 elements.
  ///
  /// #### Parameters
  /// - ``String path`` : a generic path.
  /// - ``String splitCharacter`` : the character used for the ``split()``.
  ///
  /// #### Returns
  /// ``String`` : the path containg only the 2 last elements, separated by the ``[splitCharacter]``.
  String _getShortPath(String path, {String splitCharacter = '/'}) =>
      '${path.split(splitCharacter)[path.split(splitCharacter).length - 2]}$splitCharacter${path.split(splitCharacter).last}';

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
