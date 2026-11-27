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
import 'package:cards_against_humanity/features/update/presentation/widgets/update_listener.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      '### Funzionalità\n- Vedi [qui](https://example.com) e [dangling bracket\n### Bug fixes\n- Fix 1\n- Fix 2\n- Fix 3\n- Fix 4',
    );
    expect(sections['Funzionalità']?.first, contains('https://example.com'));
    expect(sections['Bug fixes'], equals(['Fix 1', 'Fix 2', 'Fix 3', 'Fix 4']));
  });

  testWidgets(
      'UpdatePromptDialog styles headings orange and puts unlimited items in scrollable detached boxes',
      (tester) async {
    const richRelease = AppRelease(
      version: AppVersion(major: 0, minor: 4, patch: 0),
      description:
          '### Funzionalità\n- Feature 1\n- Feature 2\n- Feature 3\n- Feature 4\n### Bug fixes\n- Fix 1\n- Fix 2\n- Fix 3\n- Fix 4',
      isDraft: false,
      downloadUrl: 'https://example.com/app.apk',
      releaseUrl: 'https://example.com/release',
    );

    const orange = Color.fromARGB(255, 242, 116, 5);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color.fromARGB(255, 242, 135, 5),
            secondary: orange,
          ),
        ),
        home: Scaffold(
          body: Center(
            child: UpdatePromptDialog(
              release: richRelease,
              onConfirm: () {},
              onDeny: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester.widget<Text>(find.text('Nuova versione disponibile!')).style?.color,
      equals(orange),
    );
    expect(
      tester.widget<Text>(find.text('Funzionalità')).style?.color,
      equals(orange),
    );
    expect(
      tester.widget<Text>(find.text('Bug fixes')).style?.color,
      equals(orange),
    );
    for (final divider in tester.widgetList<Divider>(find.byType(Divider))) {
      expect(divider.color, equals(orange));
    }

    // 1 outer scrollable list between the 2 dividers + 1 ListView per section.
    expect(find.byType(ListView), findsNWidgets(3));
    expect(find.text('. . .'), findsNothing);
    expect(find.text('Feature 4'), findsOneWidget);
    expect(find.text('Fix 4'), findsOneWidget);
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

  testWidgets(
      'UpdateListener SnackBar adapts min size to screen and resizes with text & font size',
      (tester) async {
    final widgetBloc = UpdateBloc(
      checkForUpdate: CheckForUpdate(updateRepository: repo),
      downloadApk: DownloadApk(updateRepository: repo),
      installApk: InstallApk(updateRepository: repo),
      clearCachedUpdates: ClearCachedUpdates(updateRepository: repo),
      managePermission: ManageUpdatePermission(updateRepository: repo),
      permissionPromptDelay: Duration.zero,
    );
    addTearDown(widgetBloc.close);

    Future<Size> measureSnackBar({
      required Size screenSize,
      required String message,
      double fontSize = 14,
    }) async {
      tester.view.physicalSize = screenSize;
      tester.view.devicePixelRatio = 1.0;

      repo.checkResult = left(Failure(message));
      await tester.pumpWidget(
        MaterialApp(
          key: UniqueKey(),
          theme: ThemeData(
            textTheme: TextTheme(bodyMedium: TextStyle(fontSize: fontSize)),
          ),
          home: BlocProvider<UpdateBloc>.value(
            value: widgetBloc,
            child: const Scaffold(
              body: UpdateListener(child: SizedBox.expand()),
            ),
          ),
        ),
      );

      widgetBloc.add(const UpdateCheckRequested());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text(message), findsOneWidget);
      final pill = find.ancestor(
        of: find.text(message),
        matching: find.byType(Container),
      );
      final size = tester.getSize(pill.first);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      return size;
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final smallShort = await measureSnackBar(
      screenSize: const Size(320, 568),
      message: ':(',
    );
    final phoneShort = await measureSnackBar(
      screenSize: const Size(400, 800),
      message: ':(',
    );
    final tabletShort = await measureSnackBar(
      screenSize: const Size(900, 1280),
      message: ':(',
    );
    expect(smallShort.width, lessThan(phoneShort.width));
    expect(phoneShort.width, lessThan(tabletShort.width));
    expect(smallShort.height, lessThanOrEqualTo(phoneShort.height));
    expect(phoneShort.height, lessThan(tabletShort.height));

    final phoneMedium = await measureSnackBar(
      screenSize: const Size(400, 800),
      message: 'Aggiornamento non riuscito oggi',
    );
    final phoneLargeFont = await measureSnackBar(
      screenSize: const Size(400, 800),
      message: 'Aggiornamento non riuscito oggi',
      fontSize: 26,
    );
    expect(phoneMedium.width, greaterThan(phoneShort.width));
    expect(phoneLargeFont.height, greaterThan(phoneMedium.height));
  });
}
