/// Exception thrown when loading or parsing card CSV assets fails.
class DataLoadException implements Exception {
  final String message;

  const DataLoadException(this.message);
}

/// Exception thrown when checking for or downloading an app update fails.
class UpdateException implements Exception {
  final String message;

  const UpdateException(this.message);
}

/// Exception thrown when parsing a version string fails.
class VersionParseException implements Exception {
  final String message;

  const VersionParseException(this.message);

  @override
  String toString() => 'VersionParseException: $message';
}
