import 'dart:io';

import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_local_datasource.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/repository/update_repository.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/pick_and_install_apk.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/update_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class _FakeUpdateRepository implements UpdateRepository {
  Either<Failure, AppRelease?> checkResult = right(null);
  bool storageGranted = true;
  bool installGranted = true;
  Either<Failure, String> downloadResult = right('/tmp/Cards_Against_Humanity.apk');
  Either<Failure, Unit> installResult = right(unit);
  Either<Failure, Unit> pickResult = right(unit);
  List<double> reportedProgress = [0.5, 1.0];

  @override
  Future<Either<Failure, AppRelease?>> checkForUpdate() async => checkResult;

  @override
  Future<bool> hasPermission(UpdatePermission permission) async =>
      permission == UpdatePermission.externalStorage
          ? storageGranted
          : installGranted;

  @override
  Future<Either<Failure, bool>> requestPermission(
    UpdatePermission permission,
  ) async =>
      right(
        permission == UpdatePermission.externalStorage
            ? storageGranted
            : installGranted,
      );

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
  Future<Either<Failure, Unit>> installApk(String apkPath) async =>
      installResult;

  @override
  Future<Either<Failure, Unit>> pickAndInstallApk() async => pickResult;
}

void main() {
  late _FakeUpdateRepository repo;
  late UpdateBloc bloc;

  const sampleRelease = AppRelease(
    version: '0.3.0',
    description: '### Funzionalità\n- Nuova grafica\n### Bug fixes\n- Fix crash',
    isDraft: false,
    downloadUrl: 'https://example.com/app.apk',
    releaseUrl: 'https://example.com/release',
  );

  setUp(() {
    repo = _FakeUpdateRepository();
    bloc = UpdateBloc(
      checkForUpdate: CheckForUpdate(updateRepository: repo),
      downloadApk: DownloadApk(updateRepository: repo),
      installApk: InstallApk(updateRepository: repo),
      pickAndInstallApk: PickAndInstallApk(updateRepository: repo),
      managePermission: ManageUpdatePermission(updateRepository: repo),
      permissionPromptDelay: Duration.zero,
    );
  });

  tearDown(() => bloc.close());

  test('UpdateCheckRequested emits UpdateAvailable when newer release exists',
      () async {
    repo.checkResult = right(sampleRelease);
    bloc.add(const UpdateCheckRequested());
    await expectLater(bloc.stream, emits(isA<UpdateAvailable>()));
  });

  test('UpdateCheckRequested emits UpdateUpToDate when no update is available',
      () async {
    repo.checkResult = right(null);
    bloc.add(const UpdateCheckRequested());
    await expectLater(bloc.stream, emits(isA<UpdateUpToDate>()));
  });

  test('UpdateDownloadRequested emits progress and UpdateDownloadCompleted',
      () async {
    bloc.add(const UpdateDownloadRequested(sampleRelease));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<UpdateDownloadInProgress>(),
        isA<UpdateDownloadInProgress>(),
        isA<UpdateDownloadInProgress>(),
        isA<UpdateDownloadCompleted>(),
      ]),
    );
  });

  test('UpdateDownloadRequested emits notice when storage permission is denied',
      () async {
    repo.storageGranted = false;
    bloc.add(const UpdateDownloadRequested(sampleRelease));
    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<UpdateNotice>(),
        predicate<UpdateState>(
          (s) => s is UpdateNotice && s.message == 'Fottiti',
        ),
      ]),
    );
  });

  test('UpdateInstallRequested emits UpdateInstallFailed then manual pick works',
      () async {
    repo.installResult = left(
      UpdateInstallFailure(
        errorType: 'File not found',
        apkPath: '/storage/emulated/0/Download/Cards_Against_Humanity.apk',
      ),
    );
    bloc.add(
      const UpdateInstallRequested(
        '/storage/emulated/0/Download/Cards_Against_Humanity.apk',
      ),
    );
    await expectLater(
      bloc.stream,
      emits(predicate<UpdateState>(
        (s) =>
            s is UpdateInstallFailed &&
            s.errorType == 'File not found' &&
            s.apkPath.endsWith('Cards_Against_Humanity.apk'),
      )),
    );

    bloc.add(const UpdateManualInstallRequested());
    await expectLater(bloc.stream, emits(isA<UpdateInstallCompleted>()));
  });

  test('resolveAvailableFileName increments suffix and ignores malformed names',
      () {
    const local = UpdateLocalDataSourceImpl();
    final name = local.resolveAvailableFileName(
      entries: [
        File('/tmp/Cards_Against_Humanity.apk'),
        File('/tmp/Cards_Against_Humanity-2.apk'),
        File('/tmp/Cards_Against_Humanity-backup.apk'),
      ],
      baseFileName: 'Cards_Against_Humanity',
      extension: '.apk',
    );
    expect(name, equals('Cards_Against_Humanity-3.apk'));
  });

  test('parseReleaseSections safely strips markdown links without hanging', () {
    final sections = UpdatePromptDialog.parseReleaseSections(
      '### Funzionalità\n- Vedi [qui](https://example.com) e [dangling bracket\n### Bug fixes\n- Fix',
    );
    expect(sections['Funzionalità']?.first, contains('https://example.com'));
    expect(sections['Bug fixes'], equals(['Alcuni bug fixes']));
  });
}
