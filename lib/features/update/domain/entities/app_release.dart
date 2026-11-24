import 'package:cards_against_humanity/features/update/domain/entities/app_version.dart';

/// Domain entity representing an application release on GitHub.
class AppRelease {
  final AppVersion version;
  final String description;
  final bool isDraft;
  final String downloadUrl;
  final String releaseUrl;

  const AppRelease({
    required this.version,
    required this.description,
    required this.isDraft,
    required this.downloadUrl,
    required this.releaseUrl,
  });
}
