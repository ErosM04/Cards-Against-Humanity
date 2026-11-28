import '../test/utils/fake_update_repo.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_answers.dart';
import 'package:cards_against_humanity/features/load/domain/usecases/load_questions.dart';
import 'package:cards_against_humanity/features/load/presentation/bloc/load_bloc.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/check_for_update.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/clear_cached_updates.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/download_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/install_apk.dart';
import 'package:cards_against_humanity/features/update/domain/usecases/manage_update_permission.dart';
import 'package:cards_against_humanity/features/update/presentation/bloc/update_bloc.dart';
import 'package:cards_against_humanity/init_dependencies.dart';
import 'package:cards_against_humanity/main.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils/orientation_stub_load_repo.dart';

/// Runs unit and widget tests for portrait lock vs foldable/tablet rotation policy.
void main() {
  test(
      'shouldLockPortrait distinguishes narrow/tall phones from foldables and tablets',
      () {
    expect(shouldLockPortrait(Size.zero), isFalse);

    // Tall / narrow phones + foldable cover screens -> portrait lock.
    expect(shouldLockPortrait(const Size(320, 568)), isTrue);
    expect(shouldLockPortrait(const Size(360, 640)), isTrue);
    expect(shouldLockPortrait(const Size(390, 844)), isTrue);
    expect(shouldLockPortrait(const Size(412, 915)), isTrue);
    expect(shouldLockPortrait(const Size(374, 841)), isTrue);

    // Unfolded foldables + tablets -> rotation allowed.
    expect(shouldLockPortrait(const Size(540, 680)), isFalse);
    expect(shouldLockPortrait(const Size(674, 841)), isFalse);
    expect(shouldLockPortrait(const Size(600, 960)), isFalse);
    expect(shouldLockPortrait(const Size(600, 1066)), isFalse);
    expect(shouldLockPortrait(const Size(800, 1280)), isFalse);
    expect(shouldLockPortrait(const Size(768, 1024)), isFalse);
  });

  testWidgets(
      'CardsAgainstHumanity dynamically updates preferred orientations when metrics change',
      (tester) async {
    final recordedCalls = <List<String>>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'SystemChrome.setPreferredOrientations') {
          recordedCalls.add(List<String>.from(call.arguments as List));
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );

    final loadRepo = OrientationStubLoadRepo();
    final updateRepo = FakeUpdateRepository();
    serviceLocator.registerFactory<LoadBloc>(
      () => LoadBloc(
        loadQuestions: LoadQuestions(loadRepository: loadRepo),
        loadAnswers: LoadAnswers(loadRepository: loadRepo),
      ),
    );
    serviceLocator.registerFactory<UpdateBloc>(
      () => UpdateBloc(
        checkForUpdate: CheckForUpdate(updateRepository: updateRepo),
        downloadApk: DownloadApk(updateRepository: updateRepo),
        installApk: InstallApk(updateRepository: updateRepo),
        clearCachedUpdates: ClearCachedUpdates(updateRepository: updateRepo),
        managePermission: ManageUpdatePermission(updateRepository: updateRepo),
        permissionPromptDelay: Duration.zero,
      ),
    );
    addTearDown(serviceLocator.reset);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CardsAgainstHumanity());
    await tester.pump();
    expect(recordedCalls.last, equals(['DeviceOrientation.portraitUp']));

    // Simulate unfolding a foldable phone -> unlocks all orientations.
    tester.view.physicalSize = const Size(674, 841);
    await tester.pump();
    expect(recordedCalls.last.length, equals(4));

    // Opening software keyboard without crossing phone/tablet ratio should not re-emit.
    final countBeforeKeyboard = recordedCalls.length;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(tester.view.resetViewInsets);
    await tester.pump();
    expect(recordedCalls.length, equals(countBeforeKeyboard));

    // Simulate folding back to cover screen -> re-locks portrait.
    tester.view.physicalSize = const Size(374, 841);
    await tester.pump();
    expect(recordedCalls.last, equals(['DeviceOrientation.portraitUp']));

    // Flush startup explicit-warning SnackBar and 2s delayed update check timers.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  });
}
