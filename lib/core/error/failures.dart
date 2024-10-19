class Failure {
  final String message;

  Failure([this.message = '']);
}

class DataFailure extends Failure {
  /// The type of data related to the failure.
  Type dataType;

  DataFailure(super.message, {required this.dataType});
}
