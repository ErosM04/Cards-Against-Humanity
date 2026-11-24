import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';

/// Data model for deserializing a GitHub Release JSON payload.
class AppReleaseModel extends AppRelease {
  const AppReleaseModel({
    required super.version,
    required super.description,
    required super.isDraft,
    required super.downloadUrl,
    required super.releaseUrl,
  });

  /// Parses release metadata from a GitHub Releases API JSON map.
  factory AppReleaseModel.fromJson(Map<String, dynamic> json) {
    final rawTag = (json['tag_name'] ?? '').toString().trim();
    final normalizedTag =
        rawTag.startsWith('v') || rawTag.startsWith('V')
            ? rawTag.substring(1)
            : rawTag;

    return AppReleaseModel(
      version: AppVersion.parse(normalizedTag),
      description: (json['body'] ?? '').toString(),
      isDraft: json['draft'] == true,
      downloadUrl: githubLatestApkUrl,
      releaseUrl: (json['html_url'] ?? githubReleasesPageUrl).toString(),
    );
  }
}
