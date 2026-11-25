import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:fpdart/fpdart.dart';

/// In-memory [UpdateRepository] fake used to drive [UpdateBloc] unit tests.
class FakeUpdateRepository implements UpdateRepository {
  Either<Failure, AppRelease?> checkResult = right(null);
  bool installGranted = true;
  Either<Failure, String> downloadResult =
      right('/tmp/updates/Cards_Against_Humanity.apk');
  Either<Failure, Unit> installResult = right(unit);
  Either<Failure, Unit> clearCacheResult = right(unit);
  int clearCacheCalls = 0;
  List<double> reportedProgress = [0.5, 1.0];

  @override
  Future<Either<Failure, AppRelease?>> checkForUpdate() async => checkResult;

  @override
  Future<bool> hasPermission(UpdatePermission permission) async => installGranted;

  @override
  Future<Either<Failure, bool>> requestPermission(
    UpdatePermission permission,
  ) async =>
      right(installGranted);

  @override
  Future<Either<Failure, String>> downloadApk({
    required String url,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    for (final p in reportedProgress) {
      onProgress?.call(p);
    }
    return downloadResult;
  }

  @override
  Future<Either<Failure, Unit>> clearCachedUpdates() async {
    clearCacheCalls++;
    return clearCacheResult;
  }

  @override
  Future<Either<Failure, Unit>> installApk(String apkPath) async =>
      installResult;
}
