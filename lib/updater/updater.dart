import 'package:cards_against_humanity/updater/dialog.dart';
import 'package:cards_against_humanity/updater/installer.dart';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:convert';

/// Allows to check for a new version and download the latest version (if exists) into the ``Downloads`` folder
/// with the single method ``[updateToNewVersion]``.
class Updater {
  final String actualVersion = '0.1.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/Cards-Against-Humanity/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest/download/Cards_Against_Humanity.apk';
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionJson]`` to get the latest version and if it is different from the actual version, asks for update consent
  /// to the user. When asking for consent uses ``[_getLatestVersionJson]`` again to get info about the latest changes and insert them
  /// into the dialog using [DialogContent].
  void updateToNewVersion() async {
    String latestVersion =
        (await _getLatestVersionJson('tag_name')).replaceAll('v', '');

    if (latestVersion != actualVersion && latestVersion.isNotEmpty) {
      _invokeDialog(
        latestVersion: latestVersion,
        content: DialogContent(
            latestVersion: latestVersion,
            changes: await _getLatestVersionJson('body')),
      );
    }
  }

  /// Performs a request to the Github API to obtain a json about the latest release data.
  /// If anything goes wrong an [Exception] is thrown and an error message [SnackBar] is called.
  /// #### Parameters
  /// - ``String [key]`` : is the key used to get the corressponding value from the json ``{['key'] => value}``.
  ///
  /// #### Returns
  /// ``Future<String>`` : the value corresponding to ``[key]`` in the json.
  Future<String> _getLatestVersionJson(String key) async {
    int statusCode = -1;

    try {
      var response = await http.get(Uri.parse(_latestReleaseLink));
      statusCode = response.statusCode;

      if (statusCode == 200) {
        var data = json.decode(response.body);
        return data[key].toString();
      } else {
        throw Exception();
      }
    } on Exception catch (_) {
      _callSnackBar(
          message:
              'Errore $statusCode durante la ricerca di una nuova versione');
    }

    return '';
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
                content: content,
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
              ));

  /// Uses the ``[FileDownloader]`` object to downlaod the apk.
  /// A [SnackBar] is shown at the end of the download to inform the user that the app has been downloaded and saved
  /// in the ``Downloads`` folder. In case of error an error message [SnackBar] is shown. To show the snackbar
  /// ``[_callSnackBar]`` method is used.
  Future<void> _downloadUpdate(String latestVersion) async =>
      FileDownloader.downloadFile(
        url: _latestAPKLink.trim(),
        onDownloadCompleted: (path) {
          _callSnackBar(
              message:
                  'Versione $latestVersion scaricata in ${path.split('/')[4]}/${path.split('/').last}',
              durationInSec: 5);
          Future.delayed(
            const Duration(seconds: 5),
            () => Installer(context)
              ..installUpdate(
                  (path.startsWith('/')) ? path.substring(1) : path),
          );
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
