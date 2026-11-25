import 'dart:io';

import '../test/utils/fake_update_repo.dart';
import 'package:cards_against_humanity/core/errors/failures.dart';
import 'package:cards_against_humanity/features/update/data/datasources/update_local_datasource.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/clear_cached_updates.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/features/update/presentation/widgets/update_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:material_ui/material_ui.dart';

/// Runs unit and widget tests for [UpdateBloc], internal cache fallback, and dialog controls.
void main() {
  late FakeUpdateRepository repo;
  late UpdateBloc bloc;

  const sampleRelease = AppRelease(
    version: AppVersion(major: 0, minor: 3, patch: 0),
    description:
        '### Funzionalità\n- Nuova grafica\n### Bug fixes\n- Fix crash',
    isDraft: false,
    downloadUrl: 'https://example.com/app.apk',
    releaseUrl: 'https://example.com/release',
  );

  setUp(() {
    repo = FakeUpdateRepository();
    bloc = UpdateBloc(
      checkForUpdate: CheckForUpdate(updateRepository: repo),
      downloadApk: DownloadApk(updateRepository: repo),
      installApk: InstallApk(updateRepository: repo),
      clearCachedUpdates: ClearCachedUpdates(updateRepository: repo),
      managePermission: ManageUpdatePermission(updateRepository: repo),
      permissionPromptDelay: Duration.zero,
    );
  });

  tearDown(() => bloc.close());

  test('UpdateCacheClearRequested clears previously cached updates', () async {
    bloc.add(const UpdateCacheClearRequested());
    await Future<void>.delayed(Duration.zero);
    expect(repo.clearCacheCalls, equals(1));
  });

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

  test(
      'UpdateInstallRequested emits UpdateInstallFailed then retry succeeds',
      () async {
    repo.downloadResult = right('/tmp/updates/Cards_Against_Humanity.apk');
    bloc.add(const UpdateDownloadRequested(sampleRelease));
    await expectLater(bloc.stream, emitsThrough(isA<UpdateDownloadCompleted>()));

    repo.installResult = left(
      UpdateInstallFailure(
        errorType: 'File not found',
        apkPath: '/tmp/updates/Cards_Against_Humanity.apk',
      ),
    );
    bloc.add(
      const UpdateInstallRequested('/tmp/updates/Cards_Against_Humanity.apk'),
    );
    await expectLater(
      bloc.stream,
      emits(predicate<UpdateState>(
        (s) =>
            s is UpdateInstallFailed &&
            s.errorType == 'File not found' &&
            s.apkPath.endsWith('Cards_Against_Humanity.apk') &&
            s.downloadUrl == sampleRelease.downloadUrl,
      )),
    );

    repo.installResult = right(unit);
    bloc.add(
      const UpdateInstallRequested('/tmp/updates/Cards_Against_Humanity.apk'),
    );
    await expectLater(bloc.stream, emits(isA<UpdateInstallCompleted>()));
  });

  test('buildApkPath falls back from tempDir and clearCachedUpdates deletes all',
      () async {
    final sandbox = await Directory.systemTemp.createTemp('cah_update_test_');
    addTearDown(() async {
      if (await sandbox.exists()) await sandbox.delete(recursive: true);
    });

    final supportDir = Directory('${sandbox.path}${Platform.pathSeparator}support');
    final externalDir =
        Directory('${sandbox.path}${Platform.pathSeparator}external');

    final local = UpdateLocalDataSourceImpl(
      getTempDir: () async => throw const FileSystemException('no temp'),
      getSupportDir: () async => supportDir,
      getExternalDir: () async => externalDir,
    );

    final apkPath = await local.buildApkPath(fileName: 'Cards_Against_Humanity');
    expect(apkPath, startsWith('${supportDir.path}${Platform.pathSeparator}updates'));
    await File(apkPath).writeAsString('apk-bytes');
    expect(await File(apkPath).exists(), isTrue);

    final extUpdates = Directory(
      '${externalDir.path}${Platform.pathSeparator}updates',
    );
    await extUpdates.create(recursive: true);
    await File('${extUpdates.path}${Platform.pathSeparator}old.apk')
        .writeAsString('stale');

    await local.clearCachedUpdates();
    expect(
      await Directory('${supportDir.path}${Platform.pathSeparator}updates')
          .exists(),
      isFalse,
    );
    expect(await extUpdates.exists(), isFalse);
  });

  test('parseReleaseSections safely strips markdown links without hanging', () {
    final sections = UpdatePromptDialog.parseReleaseSections(
      '### Funzionalità\n- Vedi [qui](https://example.com) e [dangling bracket\n### Bug fixes\n- Fix',
    );
    expect(sections['Funzionalità']?.first, contains('https://example.com'));
    expect(sections['Bug fixes'], equals(['Alcuni bug fixes']));
  });

  testWidgets(
      'InstallErrorDialog renders Riprova and Scarica dal browser buttons',
      (tester) async {
    bool retried = false;
    bool openedBrowser = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (_) => InstallErrorDialog(
                    errorType: 'Installer error',
                    onRetry: () => retried = true,
                    onBrowserDownload: () => openedBrowser = true,
                    onDeny: () {},
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('Riprova'), findsOneWidget);
    expect(find.text('Scarica dal browser'), findsOneWidget);

    await tester.tap(find.text('Riprova'));
    await tester.pumpAndSettle();
    expect(retried, isTrue);

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scarica dal browser'));
    await tester.pumpAndSettle();
    expect(openedBrowser, isTrue);
  });
}
