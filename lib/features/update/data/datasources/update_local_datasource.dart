import 'dart:io';
import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// Contract for device-local update operations (storage paths, permissions, APK launch, file picker).
abstract interface class UpdateLocalDataSource {
  /// Returns whether [permission] is currently granted.
  Future<bool> hasPermission(UpdatePermission permission);

  /// Requests [permission] from the OS and returns whether it was granted.
  Future<bool> requestPermission(UpdatePermission permission);

  /// Builds a collision-free `.apk` destination path inside [preferredDirPath].
  Future<String> buildUniqueApkPath({
    required String baseFileName,
    String? preferredDirPath,
  });

  /// Launches the OS package installer for the APK at [apkPath].
  Future<OpenResult> openApk(String apkPath);

  /// Prompts the user to pick an `.apk` file and returns its path, or `null`.
  Future<String?> pickApkPath();
}

/// Device-local implementation of [UpdateLocalDataSource] using OS plugins and storage.
class UpdateLocalDataSourceImpl implements UpdateLocalDataSource {
  static const String _defaultDownloadPath = '/storage/emulated/0/Download';
  static const String _apkExtension = '.apk';

  const UpdateLocalDataSourceImpl();

  Permission _mapPermission(UpdatePermission permission) =>
      switch (permission) {
        UpdatePermission.externalStorage => Permission.manageExternalStorage,
        UpdatePermission.installPackages => Permission.requestInstallPackages,
      };

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
  Future<String> buildUniqueApkPath({
    required String baseFileName,
    String? preferredDirPath = _defaultDownloadPath,
  }) async {
    final dir = await _resolveDownloadDir(preferredDirPath);
    final fileName = resolveAvailableFileName(
      entries: dir.listSync(),
      baseFileName: baseFileName,
      extension: _apkExtension,
    );
    return '${dir.path}${Platform.pathSeparator}$fileName';
  }

  /// Returns [preferredDirPath] if it exists, otherwise falls back to external storage.
  Future<Directory> _resolveDownloadDir(String? preferredDirPath) async {
    if (preferredDirPath != null &&
        preferredDirPath.isNotEmpty &&
        await Directory(preferredDirPath).exists()) {
      return Directory(preferredDirPath);
    }
    try {
      final externalDir = await getExternalStorageDirectory();
      if (externalDir != null) return externalDir;
    } catch (_) {}
    throw const UpdateException("Impossibile scaricare l'aggiornamento");
  }

  /// Picks `baseFileName.apk` if unused, or `baseFileName-<max+1>.apk` to avoid collisions.
  String resolveAvailableFileName({
    required List<FileSystemEntity> entries,
    required String baseFileName,
    required String extension,
  }) {
    final defaultName = '$baseFileName$extension';
    bool hasDefault = false;
    int maxSuffix = 0;
    final pattern = RegExp(
      '^${RegExp.escape(baseFileName)}-(\\d+)${RegExp.escape(extension)}\$',
    );

    for (final entry in entries) {
      final segments = entry.uri.pathSegments.where((s) => s.isNotEmpty);
      if (segments.isEmpty) continue;
      final name = segments.last;
      if (name == defaultName) {
        hasDefault = true;
      } else {
        final match = pattern.firstMatch(name);
        final numVal = match != null ? int.tryParse(match.group(1)!) : null;
        if (numVal != null && numVal > maxSuffix) {
          maxSuffix = numVal;
        }
      }
    }

    if (!hasDefault) return defaultName;
    return '$baseFileName-${maxSuffix + 1}$extension';
  }

  @override
  Future<OpenResult> openApk(String apkPath) => OpenFilex.open(apkPath);

  @override
  Future<String?> pickApkPath() async {
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['apk'],
    );
    return picked?.path;
  }
}
