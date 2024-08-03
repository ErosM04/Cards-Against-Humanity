import 'package:cards_against_humanity/updater/dialog/dialog_builders/update_dialog_builder.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_content.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_contents/update_dialog_content.dart';
import 'package:cards_against_humanity/updater/installer.dart';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:convert';
import 'package:permission_handler/permission_handler.dart';

/// Allows to check for a new version and download the latest version (if exists) into the ``Downloads`` folder
/// with the single method ``[updateToNewVersion]``.
class Updater {
  final String actualVersion = '0.2.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/Cards-Against-Humanity/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest/download/Cards_Against_Humanity.apk';
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionJson]`` to get the latest version and if it is different from the actual version, asks for update consent
  /// to the user. When asking for consent uses ``[_getLatestVersionJson]`` again to get info about the latest changes and insert them
  /// into the dialog using [DialogContent].
  Future updateToNewVersion() async {
    var data = await _getLatestVersionData();

    if (data.isNotEmpty &&
        (data['version'].toString() != actualVersion && !data['draft'])) {
      UpdateDialogBuilder(
        context: context,
        denyButtonAction: () => _callSnackBar(message: ':('),
        confirmButtonAction: () => _downloadUpdate(data['version'].toString()),
        content: UpdateDialogContent(
          latestVersion: data['version'].toString(),
          changes: data['description'].toString(),
        ),
      ).invokeDialog();
    }

    // if (latestVersion != actualVersion && latestVersion.isNotEmpty) {
    //   UpdateDialogBuilder(
    //           context: context,
    //           confirmButtonAction: () => _downloadUpdate(latestVersion),
    //           denyButtonAction: () => _callSnackBar(message: ':('),
    //           content: UpdateDialogContent(latestVersion: latestVersion, changes: ,))
    //       .invokeDialog();
    //   // _invokeDialog(
    //   //   latestVersion: latestVersion,
    //   //   content: DialogContent(
    //   //       latestVersion: latestVersion,
    //   //       changes: await _getLatestVersionJson('body')),
    //   // );
    // }
  }

  /// Uses ``[showDialog]`` to show an [AlertDialog] over the screen.
  /// #### Parameters
  /// - ``String [latestVersion]`` : the latest version available of the app.
  /// - ``DialogContent [context]`` : the content to insert under the title in the [AlertDialog].
  void _invokeDialog({
    required String latestVersion,
    required DialogContent content,
  }) =>
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
                title: const Text('Nuova versione disponibile'),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      _callSnackBar(message: ':(');
                      Navigator.pop(context);
                    },
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      _downloadUpdate(latestVersion);
                      Navigator.pop(context);
                    },
                    child: const Text('Sì'),
                  )
                ],
                content: content,
              ));

  /// Performs a request to the Github API to obtain a json within info about the latest release data, the link used is
  /// ``[_latestReleaseLink]``.
  /// If anything goes wrong an [Exception] is thrown and an error message [CustomSnackBar] is showed.
  ///
  /// #### Returns
  /// ``Future<Map<String, String>>`` : a map containing info about the latest GitHub release of the app's repository.
  /// Returns an empty map if any error occurs.
  ///
  /// E.g.:
  /// ```
  /// {
  ///   'version' : '1.0.0',
  ///   'description' : '...',
  ///   'draft' : false,
  /// }
  /// ```
  Future<Map<String, dynamic>> _getLatestVersionData() async {
    int? statusCode;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));
      statusCode = response.statusCode;

      if (statusCode == 200) {
        var data = json.decode(response.body);
        return {
          'version': data['tag_name'].toString().replaceAll('v', ''),
          'description': data['body'].toString(),
          'draft': data['draft'],
        };
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message:
              "Errore ${statusCode ?? ''} durante la ricerca dell'aggiornamento");
      return {};
    }
  }

  /// Uses the ``[FileDownloader]`` object to downlaod the apk.
  /// A [SnackBar] is shown at the end of the download to inform the user that the app has been downloaded and saved
  /// in the ``Downloads`` folder. In case of error an error message [SnackBar] is shown. To show the snackbar
  /// ``[_callSnackBar]`` method is used.
  Future<void> _downloadUpdate(String latestVersion) async =>
      FileDownloader.downloadFile(
        url: _latestAPKLink.trim(),
        onDownloadCompleted: (path) {
          // First SnackBar that informs the user that the download completed successfully and gives the path
          _callSnackBar(
              message:
                  'Versione $latestVersion scaricata in ${path.split('/')[path.split('/').length - 2]}/${path.split('/').last}',
              durationInSec: 4);
          // Verifies if the installation package permission is granted
          Permission.requestInstallPackages.isGranted.then((res) {
            if (res) {
              // If the permission is granted, after 4 seconds (the SnackBar duration), the installation process starts
              Future.delayed(
                const Duration(seconds: 4),
                () => Installer(context)
                  ..installUpdate(
                      (path.startsWith('/')) ? path.substring(1) : path),
              );
            } else {
              // Otherwise a SnackBar informs the user that he/she will be asked to give the permisson to the app in order
              // to install an the update (the permission request will be managed by the Installer class).
              // After 8 seconds (the combined duration of both SnackBars), the request is performed.
              _callSnackBar(
                message:
                    "Ti verrà ora chiesto di dare il permesso per l'installazione dell'aggiornamento",
                durationInSec: 4,
              );
              Future.delayed(
                const Duration(seconds: 8),
                () => Installer(context)
                  ..installUpdate(
                      (path.startsWith('/')) ? path.substring(1) : path),
              );
            }
          });
        },
        onDownloadError: (errorMessage) => _callSnackBar(
            message: 'Errore durante il download $latestVersion: $errorMessage',
            durationInSec: 3),
      );

  /// Function used to simplify the invocation and the creation of a ``[SnackBar]``.
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
