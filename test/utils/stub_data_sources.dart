import 'package:cards_against_humanity/features/update/data/datasources/update_local_datasource.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_remote_datasource.dart';
import 'package:cards_against_humanity/features/update/data/models/app_release_model.dart';
import 'package:open_filex/open_filex.dart';

/// Minimal remote datasource stub returning a fixed release for version checks.
class StubRemoteDataSource implements UpdateRemoteDataSource {
  final AppReleaseModel release;

  StubRemoteDataSource(this.release);

  @override
  Future<AppReleaseModel> fetchLatestRelease() async => release;

  @override
  Future<void> downloadFile({
    required String url,
    required String destinationPath,
    void Function(double progress)? onProgress,
  }) =>
      throw UnimplementedError();
}

/// No-op local datasource stub for unit testing [UpdateRepositoryImpl].
class StubLocalDataSource implements UpdateLocalDataSource {
  @override
  Future<String> buildApkPath({required String fileName}) =>
      throw UnimplementedError();

  @override
  Future<void> clearCachedUpdates() async {}

  @override
  Future<bool> hasPermission(permission) => throw UnimplementedError();

  @override
  Future<OpenResult> openApk(String apkPath) => throw UnimplementedError();

  @override
  Future<bool> requestPermission(permission) => throw UnimplementedError();
}
