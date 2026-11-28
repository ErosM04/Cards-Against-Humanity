import 'dart:ui' show ImageFilter;

import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/widgets/snackbar.dart';
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
              _showBlurredDialog(
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
                _showBlurredDialog(
                  context,
                  BlocProvider.value(
                    value: updateBloc,
                    child: const DownloadProgressDialog(),
                  ),
                  animate: false,
                );
              }
            case UpdateDownloadCompleted(:final apkPath, :final version):
              showCustomSnackBar(
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
              showCustomSnackBar(context, message);
            case UpdateInstallFailed(
                :final errorType,
                :final apkPath,
                :final downloadUrl,
              ):
              _showBlurredDialog(
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
              showCustomSnackBar(
                context,
                message,
                durationSeconds: durationSeconds,
              );
            case UpdateInitial():
            case UpdateUpToDate():
            case UpdateInstallCompleted():
              break;
          }
        },
        child: widget.child,
      );

  /// Presents [dialog] over a slightly blurred backdrop, optionally sliding and fading in.
  void _showBlurredDialog(
    BuildContext context,
    Widget dialog, {
    bool animate = true,
  }) =>
      showGeneralDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        pageBuilder: (_, __, ___) => const SizedBox.shrink(),
        transitionDuration: const Duration(milliseconds: 180),
        transitionBuilder: (_, animation, __, ___) {
          final child = animate
              ? SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.5),
                    end: Offset.zero,
                  ).animate(animation),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.5, end: 1).animate(
                      animation,
                    ),
                    child: dialog,
                  ),
                )
              : dialog;

          return BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 4 * animation.value,
              sigmaY: 4 * animation.value,
            ),
            child: child,
          );
        },
      );
}
