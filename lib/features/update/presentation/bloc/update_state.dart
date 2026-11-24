part of 'update_bloc.dart';

/// Base state for [UpdateBloc].
@immutable
sealed class UpdateState {
  const UpdateState();
}

/// Initial state before any update check has run.
final class UpdateInitial extends UpdateState {
  const UpdateInitial();
}

/// Installed app version matches the latest published release.
final class UpdateUpToDate extends UpdateState {
  const UpdateUpToDate();
}

/// A newer non-draft release is available for download.
final class UpdateAvailable extends UpdateState {
  final AppRelease release;

  const UpdateAvailable(this.release);
}

/// Progress update emitted while downloading the APK (`0.0` to `1.0`).
final class UpdateDownloadInProgress extends UpdateState {
  final double progress;

  const UpdateDownloadInProgress(this.progress);
}

/// APK download finished successfully.
final class UpdateDownloadCompleted extends UpdateState {
  final String apkPath;
  final String version;

  const UpdateDownloadCompleted({
    required this.apkPath,
    required this.version,
  });
}

/// APK download failed before completion.
final class UpdateDownloadFailed extends UpdateState {
  final String message;

  const UpdateDownloadFailed(this.message);
}

/// APK installation was handed off cleanly to the OS package installer.
final class UpdateInstallCompleted extends UpdateState {
  const UpdateInstallCompleted();
}

/// Launching the OS package installer failed; UI should offer manual file picking.
final class UpdateInstallFailed extends UpdateState {
  final String errorType;
  final String apkPath;

  const UpdateInstallFailed({
    required this.errorType,
    required this.apkPath,
  });
}

/// Non-blocking informational or error SnackBar notice.
final class UpdateNotice extends UpdateState {
  final String message;
  final int durationSeconds;

  const UpdateNotice(this.message, {this.durationSeconds = 2});
}
