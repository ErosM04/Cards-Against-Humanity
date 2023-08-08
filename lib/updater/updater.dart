import 'package:cards_against_humanity/updater/dialog.dart';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'dart:convert';

class Updater {
  final String actualVersion = '0.1.0';
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/Cards-Against-Humanity/releases/latest';
  final String _latestAPKLink =
      'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest/download/Cards Against Humanity.apk';
  final BuildContext context;

  const Updater(this.context);

  /// If the latest version is different from the actual then asks for update consent.
  /// if the version is ahead then returns ``true``, otherwise display an error ``SnackBar`` and returns ``false``.
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

  /// Performs a request to the Github API to obtain a json about the latest release.
  /// ``key`` is the key used to get the corressponding value from the json.
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

  /// After 2 seconds shows a ``SnackBar`` to inform the user that the new version has been detected.
  /// Two seconds later downloads the latest version of the app (link4launches.apk) and save it in the Downloads folder.
  ///
  /// Every single time the download progress is updated a new ``SnackBar``containing the progress percentage is called.
  /// At the end of the download another ``SnackBar`` is called to inform the user about the path.
  /// A ``SnackBar`` is also used in case of error.
  Future<void> _downloadUpdate(String latestVersion) async =>
      FileDownloader.downloadFile(
        url: _latestAPKLink.trim(),
        onDownloadCompleted: (path) => _callSnackBar(
            message:
                'Versione $latestVersion scaricata in ${path.split('/')[4]}/${path.split('/').last}',
            durationInSec: 5),
        onDownloadError: (errorMessage) => _callSnackBar(
            message: 'Errore durante il download $latestVersion: $errorMessage',
            durationInSec: 3),
      );

  /// Function used to simplify the invocation and the creation of a ``SnackBar``.
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
