/// An exception thrown when a background task fails during execution.
///
/// This exception is used to wrap errors occurring inside an isolate task.
/// It provides a message, the original error, and the associated stack trace.
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
