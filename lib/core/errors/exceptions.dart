class DataLoadException implements Exception {
  final String message;

  const DataLoadException(this.message);
}

class UpdateException implements Exception {
  final String message;

  const UpdateException(this.message);
}
