import 'package:cards_against_humanity/old/updater/downloader.dart';
import 'package:flutter/material.dart';

/// A [Dialog] that uses **[DownloadManager]** to show [CircularProgressIndicator] (with the percentage) start and keep
/// progress of a download.
class DownloadDialog extends StatefulWidget {
  /// The latest version of the app e.g. "1.1.34".
  final String latestVersion;

  /// The title to display in the dialog.
  final String title;

  /// The url to download the file.
  final String fileLink;

  /// The name of the file, without the extension.
  final String fileName;

  /// The extension of the file, e.g. ".apk".
  final String fileExtension;

  /// The path used to download the file, if it's null then the path provided by the ``path_provider`` package is used.
  final String? downloadPath;

  /// The function to execute when the download is completed, the path is the complete ``path`` (file name included) where
  /// the file is downloaded.
  final void Function(String path)? onDownloadComplete;

  /// The function to execute every time a new data package is downlaoded (every time the download makes a progress),
  /// the ``progress`` is the number of data downloaded so far, while the ``total`` is the total amount of data to downlaod.
  final void Function(int progress, int total)? onDownloadProgress;

  /// The function to execute when an error related to path or file system occurs.
  final Function? onPathError;

  const DownloadDialog({
    required this.latestVersion,
    required this.title,
    required this.fileLink,
    required this.fileName,
    required this.fileExtension,
    this.downloadPath,
    this.onDownloadComplete,
    this.onDownloadProgress,
    this.onPathError,
    super.key,
  });

  @override
  State<DownloadDialog> createState() => _DownloadDialogState();
}

class _DownloadDialogState extends State<DownloadDialog> {
  double progress = 0;

  @override
  void initState() {
    super.initState();
    DownloadManager(latestVersion: widget.latestVersion).download(
      fileLink: widget.fileLink,
      fileName: widget.fileName,
      fileExtension: widget.fileExtension,
      downloadPath: widget.downloadPath,
      onDownloadComplete: (path) {
        Navigator.pop(context);
        if (widget.onDownloadComplete != null) {
          widget.onDownloadComplete!(path);
        }
      },
      onDownloadProgress: (progress, total) {
        if (widget.onDownloadProgress != null) {
          widget.onDownloadProgress!(progress, total);
        }
        setState(() => this.progress = progress / total);
      },
      onPathError: widget.onPathError,
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Dialog(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title and child
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Stack(alignment: AlignmentDirectional.center, children: [
                      SizedBox(
                        height: 55,
                        width: 55,
                        child: CircularProgressIndicator(
                          value: progress,
                          color: Theme.of(context).colorScheme.primary,
                          backgroundColor:
                              Theme.of(context).colorScheme.tertiary,
                          strokeWidth: 6.5,
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontSize: 13),
                      )
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
