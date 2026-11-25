import 'dart:io';
import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Contract for device-local update operations (internal cache paths, permissions, APK launch).
abstract interface class UpdateLocalDataSource {
  /// Returns whether [permission] is currently granted.
  Future<bool> hasPermission(UpdatePermission permission);

  /// Requests [permission] from the OS and returns whether it was granted.
  Future<bool> requestPermission(UpdatePermission permission);

  /// Builds a clean `.apk` destination path inside the app-private updates cache.
  Future<String> buildApkPath({required String fileName});

  /// Deletes all previously downloaded update files from app cache/fallback folders.
  Future<void> clearCachedUpdates();

  /// Launches the OS package installer for the APK at [apkPath].
  Future<OpenResult> openApk(String apkPath);
}

/// Device-local implementation of [UpdateLocalDataSource] using app-internal storage.
class UpdateLocalDataSourceImpl implements UpdateLocalDataSource {
  static const String _updatesDirName = 'updates';
  static const String _apkExtension = '.apk';

  final Future<Directory> Function() _getTempDir;
  final Future<Directory> Function() _getSupportDir;
  final Future<Directory?> Function() _getExternalDir;

  const UpdateLocalDataSourceImpl({
    Future<Directory> Function() getTempDir = getTemporaryDirectory,
    Future<Directory> Function() getSupportDir = getApplicationSupportDirectory,
    Future<Directory?> Function() getExternalDir = getExternalStorageDirectory,
  })  : _getTempDir = getTempDir,
        _getSupportDir = getSupportDir,
        _getExternalDir = getExternalDir;

  Permission _mapPermission(UpdatePermission permission) =>
      switch (permission) {
        UpdatePermission.installPackages => Permission.requestInstallPackages,
      };

  List<Future<Directory?> Function()> get _dirProviders => [
        _getTempDir,
        _getSupportDir,
        _getExternalDir,
      ];

  @override
  Future<bool> hasPermission(UpdatePermission permission) =>
      _mapPermission(permission).isGranted;

  @override
  Future<bool> requestPermission(UpdatePermission permission) async {
    final target = _mapPermission(permission);
    if (await target.isGranted) return true;
    return await target.request().isGranted;
  }

  @override
  Future<String> buildApkPath({required String fileName}) async {
    final dir = await _resolveUpdatesDir();
    final apkFile = File(
      '${dir.path}${Platform.pathSeparator}$fileName$_apkExtension',
    );
    if (await apkFile.exists()) {
      await apkFile.delete();
    }
    return apkFile.path;
  }

  @override
  Future<void> clearCachedUpdates() async {
    for (final getDir in _dirProviders) {
      try {
        final baseDir = await getDir();
        if (baseDir == null) continue;
        final updatesDir = Directory(
          '${baseDir.path}${Platform.pathSeparator}$_updatesDirName',
        );
        if (await updatesDir.exists()) {
          await updatesDir.delete(recursive: true);
        }
      } catch (_) {}
    }
  }

  /// Resolves the private updates directory, falling back if `getTemporaryDirectory` fails.
  Future<Directory> _resolveUpdatesDir() async {
    for (final getDir in _dirProviders) {
      try {
        final baseDir = await getDir();
        if (baseDir == null) continue;
        final updatesDir = Directory(
          '${baseDir.path}${Platform.pathSeparator}$_updatesDirName',
        );
        await updatesDir.create(recursive: true);
        return updatesDir;
      } catch (_) {}
    }
    throw const UpdateException("Impossibile scaricare l'aggiornamento");
  }

  @override
  Future<OpenResult> openApk(String apkPath) => OpenFilex.open(apkPath);
}
