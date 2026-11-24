import '../test/utils/stub_data_sources.dart';
import 'package:cards_against_humanity/core/errors/exceptions.dart';
import 'package:cards_against_humanity/features/update/data/models/app_release_model.dart';
import 'package:cards_against_humanity/features/update/data/repository/update_repository_impl.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';
import 'package:flutter_test/flutter_test.dart';

/// Runs unit tests for [AppVersion] parsing, operators, and update checks.
void main() {
  test('AppVersion.parse splits first two dots and strips leading dash', () {
    final beta = AppVersion.parse('1.7.34-beta3');
    expect(beta.major, equals(1));
    expect(beta.minor, equals(7));
    expect(beta.patch, equals(34));
    expect(beta.additionalInfo, equals('beta3'));
    expect(beta.toString(), equals('1.7.34-beta3'));

    final dottedSuffix = AppVersion.parse('2.0.1-rc.1-hotfix');
    expect(dottedSuffix.major, equals(2));
    expect(dottedSuffix.minor, equals(0));
    expect(dottedSuffix.patch, equals(1));
    expect(dottedSuffix.additionalInfo, equals('rc.1-hotfix'));

    final plain = AppVersion.parse('0.1.0');
    expect(plain.major, equals(0));
    expect(plain.minor, equals(1));
    expect(plain.patch, equals(0));
    expect(plain.additionalInfo, isNull);
  });

  test('AppVersion.parse throws VersionParseException on malformed strings',
      () {
    for (final invalid in [
      '',
      '1',
      '1.2',
      '1.2.3-',
      '1.a.3',
      '-1.2.3',
      '1.2.3beta',
    ]) {
      expect(
        () => AppVersion.parse(invalid),
        throwsA(isA<VersionParseException>()),
        reason: 'Expected VersionParseException for "$invalid"',
      );
    }
  });

  test(
      'AppVersion comparison operators follow major -> minor -> patch -> suffix',
      () {
    final v100 = AppVersion.parse('1.0.0');
    final v100Beta = AppVersion.parse('1.0.0-beta3');
    final v100Rc = AppVersion.parse('1.0.0-rc1');
    final v101 = AppVersion.parse('1.0.1');
    final v120 = AppVersion.parse('1.2.0');
    final v200 = AppVersion.parse('2.0.0');

    expect(v100 == AppVersion.parse('1.0.0'), isTrue);
    expect(v100Beta == AppVersion.parse('1.0.0-beta3'), isTrue);
    expect(v100 == v100Beta, isFalse);

    expect(v200 > v120, isTrue);
    expect(v120 > v101, isTrue);
    expect(v101 > v100Beta, isTrue);
    expect(v100Beta > v100, isTrue);
    expect(v100 < v100Beta, isTrue);
    expect(v100Rc > v100Beta, isTrue);
  });

  test('AppReleaseModel.fromJson parses tag_name with leading v intact suffix',
      () {
    final model = AppReleaseModel.fromJson({
      'tag_name': 'v1.7.34-dev1',
      'body': 'notes',
      'draft': false,
      'html_url': 'https://example.com',
    });
    expect(model.version, equals(AppVersion.parse('1.7.34-dev1')));
  });

  test('UpdateRepositoryImpl.checkForUpdate compares AppVersion order',
      () async {
    final olderRemote = AppReleaseModel.fromJson({
      'tag_name': 'v0.1.0',
      'body': '',
      'draft': false,
    });
    final repo = UpdateRepositoryImpl(
      remoteDataSource: StubRemoteDataSource(olderRemote),
      localDataSource: StubLocalDataSource(),
      currentVersion: '0.2.0',
    );

    final res = await repo.checkForUpdate();
    expect(res.getOrElse((_) => throw AssertionError()), isNull);
  });
}
