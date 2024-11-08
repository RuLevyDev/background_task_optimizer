# Changelog

## [1.1.0-dev] - 2024-11-08
### Added
- Introduced `runExpensiveOperationWith<T>` method with an optional `timeout` parameter:
  - Allows running a heavy operation in an isolate with optional timeout handling.
  - Throws a `TimeoutException` if the operation exceeds the specified duration.
  - Automatically kills the isolate upon completion or in case of an error.
- Added detailed in-line documentation to `BackgroundTask` class:
  - Each method now includes comments explaining parameters, behavior, and error handling.
  - Class-level and in-line comments provide further guidance on isolate management and operation execution.

### Improved
- Updated error handling in `_executeOperation` to log any exceptions that occur within the isolate.
- Enhanced error propagation to ensure all errors encountered in the background isolate are rethrown to the caller.

## [1.0.0] - 2024-11-07
### Added
- Initial release of `BackgroundTask` class with `runExpensiveOperation<T>` method:
  - Executes heavy operations in a separate isolate and returns the result.
  - Logs errors that occur during the isolate operation and rethrows exceptions to the caller.
