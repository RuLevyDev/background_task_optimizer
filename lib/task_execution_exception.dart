/// A custom exception for task execution failures, providing more detailed information.
class TaskExecutionException implements Exception {
  /// A descriptive error message explaining the reason for the exception.
  final String message;

  /// The underlying cause of the exception, if available.
  final Object? cause;

  /// The stack trace at the moment the exception was thrown, if available.
  final StackTrace? stackTrace;

  /// Creates a [TaskExecutionException] with a message, an optional cause, and an optional stack trace.
  TaskExecutionException(this.message, [this.cause, this.stackTrace]);

  @override
  String toString() {
    final causeMsg = cause != null ? ' Cause: $cause' : '';
    return '$message$causeMsg';
  }
}
