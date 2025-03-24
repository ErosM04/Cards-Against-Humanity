/// Defines a basic failure in a process.
class Failure {
  final String message;

  Failure([this.message = '']);
}

/// Defines a failure when managing data.
class DataFailure extends Failure {
  /// The type of data related to the failure
  Type dataType;

  DataFailure(super.message, {required this.dataType});
}

/// Defines a failure related to values being out of a defined range.
class DataRangeFailure extends DataFailure {
  DataRangeFailure({required super.dataType})
      : super("Value/s out of range or the container is empty");
}
