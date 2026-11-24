import 'package:cards_against_humanity/constants.dart';
import 'package:cards_against_humanity/features/update/domain/entities/app_release.dart';

/// Data model for deserializing a GitHub Release JSON payload.
class AppReleaseModel extends AppRelease {
  const AppReleaseModel({
    required super.version,
    required super.description,
    required super.isDraft,
    required super.downloadUrl,
    required super.releaseUrl,
  });

  factory AppReleaseModel.fromJson(Map<String, dynamic> json) =>
      AppReleaseModel(
        version: (json['tag_name'] ?? '').toString().replaceAll('v', ''),
        description: (json['body'] ?? '').toString(),
        isDraft: json['draft'] == true,
        downloadUrl: githubLatestApkUrl,
        releaseUrl: (json['html_url'] ?? githubReleasesPageUrl).toString(),
      );
}
