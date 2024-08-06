import 'package:cards_against_humanity/updater/downloader.dart';
import 'package:flutter/material.dart';

class DownloadDialog extends StatefulWidget {
  final DownloadManager downloader;
  final String title;
  final String fileLink;
  final String fileName;
  final String fileExtension;
  final String downloadPath;
  final void Function(String path)? onDownloadComplete;
  final void Function(int progress, int total)? onDownloadProgress;
  final Function? onPathError;

  const DownloadDialog({
    required this.downloader,
    required this.title,
    required this.fileLink,
    required this.fileName,
    required this.fileExtension,
    required this.downloadPath,
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
    widget.downloader.download(
      fileLink: widget.fileLink,
      fileName: widget.fileName,
      fileExtension: widget.fileExtension,
      downloadPath: widget.downloadPath,
      onDownloadComplete: (path) {
        if (widget.onDownloadComplete != null) widget.onDownloadComplete!(path);
        Navigator.pop(context);
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
