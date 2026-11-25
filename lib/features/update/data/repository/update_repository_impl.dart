import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_local_datasource.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_remote_datasource.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:open_filex/open_filex.dart';

/// Repository coordinating remote release fetches and local APK storage/installation.
class UpdateRepositoryImpl implements UpdateRepository {
  final UpdateRemoteDataSource remoteDataSource;
  final UpdateLocalDataSource localDataSource;
  final String currentVersion;

  const UpdateRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    this.currentVersion = appVersion,
  });

  @override
  Future<Either<Failure, AppRelease?>> checkForUpdate() async {
    try {
      final latest = await remoteDataSource.fetchLatestRelease();
      final installed = AppVersion.parse(currentVersion);
      if (!latest.isDraft && latest.version > installed) {
        return right(latest);
      }
      return right(null);
    } on UpdateException catch (e) {
      return left(Failure(e.message));
    } on VersionParseException catch (e) {
      return left(Failure(e.message));
    } catch (e) {
      return left(Failure("Errore durante la ricerca dell'aggiornamento"));
    }
  }

  @override
  Future<bool> hasPermission(UpdatePermission permission) =>
      localDataSource.hasPermission(permission);

  @override
  Future<Either<Failure, bool>> requestPermission(
    UpdatePermission permission,
  ) async {
    try {
      return right(await localDataSource.requestPermission(permission));
    } catch (e) {
      return left(UpdatePermissionFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> downloadApk({
    required String url,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final destinationPath = await localDataSource.buildApkPath(
        fileName: fileName,
      );
      await remoteDataSource.downloadFile(
        url: url,
        destinationPath: destinationPath,
        onProgress: onProgress,
      );
      return right(destinationPath);
    } on UpdateException catch (e) {
      return left(Failure(e.message));
    } catch (_) {
      return left(Failure("Impossibile scaricare l'aggiornamento"));
    }
  }

  @override
  Future<Either<Failure, Unit>> clearCachedUpdates() async {
    try {
      await localDataSource.clearCachedUpdates();
      return right(unit);
    } catch (e) {
      return left(Failure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> installApk(String apkPath) async {
    try {
      final result = await localDataSource.openApk(apkPath);
      if (result.type != ResultType.done) {
        return left(UpdateInstallFailure(
          errorType: result.message,
          apkPath: apkPath,
        ));
      }
      return right(unit);
    } catch (e) {
      return left(UpdateInstallFailure(
        errorType: e.toString(),
        apkPath: apkPath,
      ));
    }
  }
}
