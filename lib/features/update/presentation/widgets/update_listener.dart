import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/update_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:url_launcher/url_launcher.dart';

/// Listens to [UpdateBloc] state changes and presents update dialogs and SnackBars.
class UpdateListener extends StatefulWidget {
  final Widget child;

  const UpdateListener({super.key, required this.child});

  @override
  State<UpdateListener> createState() => _UpdateListenerState();
}

class _UpdateListenerState extends State<UpdateListener> {
  bool _isDownloadDialogOpen = false;

  @override
  Widget build(BuildContext context) => BlocListener<UpdateBloc, UpdateState>(
        listener: (context, state) {
          if (state is! UpdateDownloadInProgress && _isDownloadDialogOpen) {
            _isDownloadDialogOpen = false;
            Navigator.of(context, rootNavigator: true).pop();
          }

          switch (state) {
            case UpdateAvailable(:final release):
              _showAnimatedDialog(
                context,
                UpdatePromptDialog(
                  release: release,
                  onDeny: () =>
                      context.read<UpdateBloc>().add(const UpdateDeclined()),
                  onConfirm: () => context
                      .read<UpdateBloc>()
                      .add(UpdateDownloadRequested(release)),
                ),
              );
            case UpdateDownloadInProgress():
              if (!_isDownloadDialogOpen) {
                _isDownloadDialogOpen = true;
                final updateBloc = context.read<UpdateBloc>();
                showGeneralDialog(
                  context: context,
                  barrierDismissible: false,
                  pageBuilder: (_, __, ___) => const SizedBox.shrink(),
                  transitionDuration: const Duration(milliseconds: 180),
                  transitionBuilder: (_, __, ___, ____) => BlocProvider.value(
                    value: updateBloc,
                    child: const DownloadProgressDialog(),
                  ),
                );
              }
            case UpdateDownloadCompleted(:final apkPath, :final version):
              _showSnackBar(
                context,
                'Versione $version scaricata, avvio installazione...',
                durationSeconds: 4,
              );
              Future.delayed(const Duration(seconds: 4), () {
                if (context.mounted) {
                  context
                      .read<UpdateBloc>()
                      .add(UpdateInstallRequested(apkPath));
                }
              });
            case UpdateDownloadFailed(:final message):
              _showSnackBar(context, message);
            case UpdateInstallFailed(
                :final errorType,
                :final apkPath,
                :final downloadUrl,
              ):
              _showAnimatedDialog(
                context,
                InstallErrorDialog(
                  errorType: errorType,
                  onRetry: () => context
                      .read<UpdateBloc>()
                      .add(UpdateInstallRequested(apkPath)),
                  onBrowserDownload: () {
                    final target = downloadUrl.isNotEmpty
                        ? downloadUrl
                        : githubLatestApkUrl;
                    launchUrl(
                      Uri.parse(target),
                      mode: LaunchMode.externalApplication,
                    );
                    context
                        .read<UpdateBloc>()
                        .add(const UpdateCacheClearRequested());
                  },
                  onDeny: () =>
                      context.read<UpdateBloc>().add(const UpdateDeclined()),
                ),
              );
            case UpdateNotice(:final message, :final durationSeconds):
              _showSnackBar(context, message, durationSeconds: durationSeconds);
            case UpdateInitial():
            case UpdateUpToDate():
            case UpdateInstallCompleted():
              break;
          }
        },
        child: widget.child,
      );

  /// Presents [dialog] with a slide-and-fade entrance transition.
  void _showAnimatedDialog(BuildContext context, Widget dialog) =>
      showGeneralDialog(
        context: context,
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (_, animation, __, ___) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0.0, 0.5),
            end: Offset.zero,
          ).animate(animation),
          child: FadeTransition(
            opacity: Tween<double>(begin: 0.5, end: 1).animate(animation),
            child: dialog,
          ),
        ),
      );

  /// Displays a floating rounded SnackBar sized to [message] and screen dimensions.
  void _showSnackBar(
    BuildContext context,
    String message, {
    int durationSeconds = 2,
  }) {
    final screenSize = MediaQuery.sizeOf(context);
    final minWidth = (screenSize.width * 0.35).clamp(110.0, 260.0);
    final minHeight = (screenSize.height * 0.055).clamp(40.0, 64.0);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        padding: EdgeInsets.zero,
        duration: Duration(seconds: durationSeconds),
        backgroundColor: Colors.transparent,
        content: Center(
          heightFactor: 1,
          child: Container(
            constraints: BoxConstraints(
              minWidth: minWidth,
              minHeight: minHeight,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
