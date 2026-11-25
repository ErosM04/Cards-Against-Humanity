import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:fpdart/fpdart.dart';

/// Permissions required during the update installation flow.
enum UpdatePermission {
  installPackages,
}

/// Contract for checking, downloading, cleaning, and installing application updates.
abstract interface class UpdateRepository {
  /// Returns the latest [AppRelease] if a newer non-draft version exists, or `null` if up-to-date.
  Future<Either<Failure, AppRelease?>> checkForUpdate();

  /// Checks whether [permission] is currently granted.
  Future<bool> hasPermission(UpdatePermission permission);

  /// Requests [permission] from the OS, returning `true` if granted.
  Future<Either<Failure, bool>> requestPermission(UpdatePermission permission);

  /// Downloads the APK from [url] into app-internal storage, reporting progress in `[0.0, 1.0]`.
  Future<Either<Failure, String>> downloadApk({
    required String url,
    required String fileName,
    void Function(double progress)? onProgress,
  });

  /// Deletes any cached update APKs from internal storage.
  Future<Either<Failure, Unit>> clearCachedUpdates();

  /// Launches the OS package installer for the APK at [apkPath].
  Future<Either<Failure, Unit>> installApk(String apkPath);
}
