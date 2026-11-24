import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/update_dialog.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';

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
                'Versione $version scaricata in ${_shortPath(apkPath)}',
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
            case UpdateInstallFailed(:final errorType, :final apkPath):
              _showAnimatedDialog(
                context,
                InstallErrorDialog(
                  errorType: errorType,
                  shortPath: _shortPath(apkPath),
                  onDeny: () =>
                      context.read<UpdateBloc>().add(const UpdateDeclined()),
                  onConfirm: () => context
                      .read<UpdateBloc>()
                      .add(const UpdateManualInstallRequested()),
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

  /// Displays a floating rounded SnackBar containing [message].
  void _showSnackBar(
    BuildContext context,
    String message, {
    int durationSeconds = 2,
  }) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          elevation: 0,
          behavior: SnackBarBehavior.floating,
          width: double.infinity,
          duration: Duration(seconds: durationSeconds),
          backgroundColor: Colors.transparent,
          content: Container(
            height: message.length <= 40 ? 45 : 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: Colors.black,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7),
            child: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );

  /// Extracts the last two segments of [path] for compact display.
  String _shortPath(String path) {
    final segments = Uri.file(path).pathSegments.where((s) => s.isNotEmpty).toList();
    if (segments.length < 2) return path;
    return '${segments[segments.length - 2]}/${segments.last}';
  }
}
