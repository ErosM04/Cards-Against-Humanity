import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

/// Manage the download of a file using the ``dio`` package.
class DownloadManager {
  /// The latest version of the app, e.g. "1.4.5".
  final String latestVersion;

  const DownloadManager({required this.latestVersion});

  /// Retrives the directory path (with ``[_getDownloadDir]``) and an available file name (with ``[_getFinalFileName]``).
  /// Than proceed to download the file.
  ///
  /// #### Parameters:
  /// - ``String fileLink`` : the url to download the file;
  /// - ``String fileName`` : the name of the file, without the extension;
  /// - ``String fileExtension`` : the extension of the file, e.g. ".apk";
  /// - ``void Function(String path)? onDownloadComplete`` : the function to execute when the download is completed,
  /// the path is the complete ``path`` (file name included) where the file is downloaded;
  /// - ``void Function(int progress, int total)? onDownloadProgress`` : the function to execute every time a new data
  /// package is downlaoded (every time the download makes a progress), the ``progress`` is the number of data downloaded;
  /// so far, while the ``total`` is the total amount of data to downlaod;
  /// - ``Function? onPathError`` : the function to execute when an error related to path or file system occurs;
  /// - ``String? downloadPath`` : the path used to download the file, if it's null then the path provided by the
  /// ``path_provider`` package is used, e.g. ``'/storage/emulated/0/Download'``.
  void download({
    required String fileLink,
    required String fileName,
    required String fileExtension,
    void Function(String path)? onDownloadComplete,
    void Function(int progress, int total)? onDownloadProgress,
    Function? onPathError,
    String? downloadPath,
  }) async {
    var downloadDir = await _getDownloadDir(downloadPath: downloadPath);

    if (downloadDir.path.isEmpty && onPathError != null) onPathError();

    // Final path containing both path and file name with extension
    String finalCompletePath = '${downloadDir.path}/${_getFinalFileName(
      dir: downloadDir,
      fileName: fileName,
      fileExtension: fileExtension,
    )}';

    await Dio().download(
      fileLink,
      finalCompletePath,
      onReceiveProgress: (count, total) {
        if (onDownloadProgress != null) onDownloadProgress(count, total);

        if (count == total && onDownloadComplete != null) {
          onDownloadComplete(finalCompletePath);
        }
      },
    );
  }

  /// Checks weather the given ``[downloadPath]`` exists and returns it as a [Directory], otherwise use the
  /// ``[getExternalStorageDirectory]`` method.
  ///
  /// #### Parameter
  /// - ``String? downloadPath`` : the download path, e.g. ``'/storage/emulated/0/Download'``.
  Future<Directory> _getDownloadDir({String? downloadPath}) async {
    if (downloadPath != null &&
        downloadPath.isNotEmpty &&
        (await Directory(downloadPath).exists())) {
      return Directory(downloadPath);
    } else {
      try {
        return (await getExternalStorageDirectory())!;
      } on Exception {
        return Directory('');
      }
    }
  }

  /// Checks in the given ``[dir]`` if a file named ``[fileName]``, with the ``[fileExtension]`` extension, exists.
  /// If it doesen't exists, simply returns [fileName] + [fileExtension].
  ///
  /// If the file already exists a list of all files in the [dir] is iterated and all the file named "[fileName]-n[fileExtension]",
  /// where n is any number, takes the biggest n (with ``[_getHighestAvailableNumber]``) and than creates a file that
  /// ends with "x" (where x = n+1).
  ///
  /// #### Parameters
  /// - ``Directory dir`` : the direcotry where the files are stored;
  /// - ``String fileName`` : the name of the file, without the extension;
  /// - ``String fileExtension`` : the extension of the file, e.g. ".apk".
  ///
  /// #### Returns
  /// ``String`` : the name of the file, which is also not already taken in the folder.
  String _getFinalFileName({
    required Directory dir,
    required String fileName,
    required String fileExtension,
  }) {
    var content = dir.listSync();
    bool isNormal = false;
    List<String> numberList = [];

    // Iterates all file in the direcotry
    for (var element in content) {
      var file = element.path.split('/').last;

      if (file == fileName + fileExtension) {
        isNormal = true;
      } else if (RegExp(r'\b' +
              RegExp.escape(fileName) +
              r'(-\d+)?' +
              RegExp.escape(fileExtension) +
              r'$')
          .hasMatch(file)) {
        numberList.add(file.split('-').last.split('.').first);
      }
    }

    // A file named fileName + fileExtension already exists
    if (isNormal) {
      // There are no file named fileName -n + fileExtension, so we create a file that ends with -1
      if (numberList.isEmpty) {
        return '$fileName-1$fileExtension';
      } else {
        // There are more files that after fileNmae have -1, -2, -45, ... So we take the biggst one (e.g. 46)
        return '$fileName-${_getHighestAvailableNumber(numberList)}$fileExtension';
      }
    }

    // Non esiste un file che si chiama fileName + fileExtension, quindi lo possiamo creare
    return fileName + fileExtension;
  }

  /// Iterates in a list of numbers in a [String] format and returns the highest + 1.
  ///
  /// #### Parameter
  /// - ``List<String> list`` : the list of number, e.g. ``["1", "45", "3"]``.
  ///
  /// #### Returns
  /// ``String`` : the highest number + 1.
  String _getHighestAvailableNumber(List<String> list) {
    String max = '1';
    for (var number in list) {
      if (int.parse(max) < int.parse(number)) max = number;
    }
    return (int.parse(max) + 1).toString();
  }
}
