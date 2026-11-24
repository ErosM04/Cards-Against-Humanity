/// Domain entity representing an application release on GitHub.
class AppRelease {
  final String version;
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
