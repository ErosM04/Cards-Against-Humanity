part of 'update_bloc.dart';

/// Base event for [UpdateBloc].
@immutable
sealed class UpdateEvent {
  const UpdateEvent();
}

/// Clears any leftover update APKs from app-internal cache storage.
final class UpdateCacheClearRequested extends UpdateEvent {
  const UpdateCacheClearRequested();
}

/// Checks GitHub for a newer release.
final class UpdateCheckRequested extends UpdateEvent {
  const UpdateCheckRequested();
}

/// User declined the available update or installation fallback.
final class UpdateDeclined extends UpdateEvent {
  const UpdateDeclined();
}

/// User accepted the update prompt; starts APK download into internal cache.
final class UpdateDownloadRequested extends UpdateEvent {
  final AppRelease release;

  const UpdateDownloadRequested(this.release);
}

/// Requests OS installation of the downloaded APK at [apkPath].
final class UpdateInstallRequested extends UpdateEvent {
  final String apkPath;

  const UpdateInstallRequested(this.apkPath);
}
