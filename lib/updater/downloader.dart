import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

class DownloadManager {
  final String latestVersion;

  const DownloadManager({required this.latestVersion});

  /// Es. '/storage/emulated/0/Download'
  void download({
    required String fileLink,
    required String fileName,
    required String fileExtension,
    required void Function(String path) onDownloadComplete,
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

    print('Final path: $finalCompletePath');

    await Dio().download(
      fileLink,
      finalCompletePath,
      onReceiveProgress: (count, total) {
        if (count == total) onDownloadComplete(finalCompletePath);
      },
    );
  }

  Future<Directory> _getDownloadDir({required String? downloadPath}) async {
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

  String _getFinalFileName({
    required Directory dir,
    required String fileName,
    required String fileExtension,
  }) {
    var content = dir.listSync();
    bool isNormal = false;
    List<String> numberList = [];

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

    // Vi è solo un file che si chiama fileName + fileExtension
    if (isNormal) {
      if (numberList.isEmpty) {
        // Quindi ne creiamo uno che termini con -1
        return '$fileName-1$fileExtension';
      } else {
        // Vi sono anche file che dopo il nome hanno -1, -2, -45, ... Quindi bisogna prendere il numero più alto libero (es. 46)
        return '$fileName-${getHighestAvailableNumber(numberList)}$fileExtension';
      }
    }

    // Non esiste un file che si chiama fileName + fileExtension, quindi lo possiamo creare
    return fileName + fileExtension;
  }

  String getHighestAvailableNumber(List<String> list) {
    String max = '1';
    for (var number in list) {
      if (int.parse(max) < int.parse(number)) max = number;
    }
    return (int.parse(max) + 1).toString();
  }
}
