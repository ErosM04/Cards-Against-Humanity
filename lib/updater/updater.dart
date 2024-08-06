import 'package:cards_against_humanity/updater/dialog/dialog_builders/update_dialog_builder.dart';
import 'package:cards_against_humanity/updater/dialog/dialog_contents/update_dialog_content.dart';
import 'package:cards_against_humanity/updater/dialog/download_dialog.dart';
import 'package:cards_against_humanity/updater/downloader.dart';
import 'package:cards_against_humanity/updater/installer.dart';
import 'package:cards_against_humanity/updater/permission.dart';
import 'package:cards_against_humanity/updater/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Allows to check for a new version and download the latest version (if exists) into the ``Downloads`` folder
/// with the single method ``[updateToNewVersion]``.
class Updater {
  /// Current version of the app, needs to be updated every time a new release is built.
  final String actualVersion = '0.2.0';

  /// The link to get a json containg the latest GitHub release information (for the app).
  final String _latestReleaseLink =
      'https://api.github.com/repos/ErosM04/Cards-Against-Humanity/releases/latest';

  /// The link to get the update apk file.
  final String _latestAPKLink =
      'https://github.com/ErosM04/Cards-Against-Humanity/releases/latest/download/Cards_Against_Humanity.apk';

  /// App context used for various widgets.
  final BuildContext context;

  const Updater(this.context);

  /// Uses ``[_getLatestVersionData]`` to get the latest release info (such as version, description...). If the GitHub
  /// release isn't a draft and the version is different from the actual version, invoke an ``[UpdateDialogBuilder]`` that
  /// will ask the user if he wants to download the update ``[_downloadUpdate]``.
  void updateToNewVersion() async {
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
  }

  /// Performs a request to the Github API to obtain a json within info about the latest release data, the link used is
  /// ``[_latestReleaseLink]``.
  /// If anything goes wrong an [Exception] is thrown and an error message [SnackBarMessage] is showed.
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

  /// Uses the ``[DownloadManager]`` object to downlaod the apk.
  /// A [SnackBar] is shown at the end of the download to inform the user that the app has been downloaded and saved
  /// in the ``Downloads`` folder. In case of error an error message [SnackBar] is shown. To show the snackbar
  /// ``[_callSnackBar]`` method is used.
  void _downloadUpdate(String latestVersion) async {
    PermissionChecker.requestExternalStorage(
      onGranted: () => invokeDownloadDialog(latestVersion),
      // onGranted: () => DownloadManager(latestVersion: latestVersion)
      //   ..download(
      //     fileLink: _latestAPKLink,
      //     fileName: 'Cards_Against_Humanity',
      //     fileExtension: '.apk',
      //     downloadPath: '/storage/emulated/0/Download',
      //     onPathError: () =>
      //         _callSnackBar(message: "Impossibile scaricare l'aggiornamento"),
      //     onDownloadComplete: (path) {
      //       _callSnackBar(
      //         message:
      //             'Versione $latestVersion scaricata in ${_getShortPath(path)}',
      //         durationInSec: 4,
      //       );

      //       Future.delayed(const Duration(seconds: 4),
      //           () => Installer(context)..installUpdate(path));
      //     },
      //   ),
      onDenied: () => {_callSnackBar(message: 'Fottiti')},
    );
  }

  void invokeDownloadDialog(String latestVersion) => showGeneralDialog(
        context: context,
        pageBuilder: (context, animation, secondaryAnimation) => Container(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (context, animation, secondaryAnimation, child) =>
            DownloadDialog(
          downloader: DownloadManager(latestVersion: latestVersion),
          title: 'Download in corso',
          fileLink: _latestAPKLink,
          fileName: 'Cards_Against_Humanity',
          fileExtension: '.apk',
          downloadPath: '/storage/emulated/0/Download',
          onPathError: () =>
              _callSnackBar(message: "Impossibile scaricare l'aggiornamento"),
          onDownloadComplete: (path) {
            _callSnackBar(
              message:
                  'Versione $latestVersion scaricata in ${_getShortPath(path)}',
              durationInSec: 4,
            );
            Future.delayed(const Duration(seconds: 4),
                () => Installer(context)..installUpdate(path));
          },
        ),
      );

  /// Function used to simplify the invocation and the creation of a ``[SnackBar]``. Uses ``[SnackBarMessage]``
  void _callSnackBar(
          {required String message,
          int durationInSec = 2,
          int? durationInMil}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBarMessage(
              message: message,
              durationInSec: durationInSec,
              durationInMil: durationInMil)
          .build(context));

  /// Thakes a ``[path]`` and split that based on ``[splitCharacter]``, then returns a path containg only the last 2 elements.
  ///
  /// #### Parameters
  /// - ``String path`` : a generic path.
  /// - ``String splitCharacter`` : the character used for the ``split()``.
  ///
  /// #### Returns
  /// ``String`` : the path containg only the 2 last elements, separated by the ``[splitCharacter]``.
  String _getShortPath(String path, {String splitCharacter = '/'}) =>
      '${path.split(splitCharacter)[path.split(splitCharacter).length - 2]}$splitCharacter${path.split(splitCharacter).last}';
}
