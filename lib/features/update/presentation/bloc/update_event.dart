part of 'update_bloc.dart';

/// Base event for [UpdateBloc].
@immutable
sealed class UpdateEvent {
  const UpdateEvent();
}

/// Checks GitHub for a newer release.
final class UpdateCheckRequested extends UpdateEvent {
  const UpdateCheckRequested();
}

/// User declined the available update or manual fallback.
final class UpdateDeclined extends UpdateEvent {
  const UpdateDeclined();
}

/// User accepted the update prompt; starts permission check and APK download.
final class UpdateDownloadRequested extends UpdateEvent {
  final AppRelease release;

  const UpdateDownloadRequested(this.release);
}

/// Requests OS installation of the downloaded APK at [apkPath].
final class UpdateInstallRequested extends UpdateEvent {
  final String apkPath;

  const UpdateInstallRequested(this.apkPath);
}

/// Opens the system file picker so the user can manually select and install an `.apk`.
final class UpdateManualInstallRequested extends UpdateEvent {
  const UpdateManualInstallRequested();
}
