// author: Ruben Orero Levy
// email: rulevydeveloper@gmail.com
// createdate:  08/11/2024
// ︻デ═一

import 'dart:async';
import 'dart:developer' as developer;
import 'dart:isolate';

/// A utility class to perform heavy tasks in a separate isolate.
class BackgroundTask {
  /// Executes a computationally expensive [operation] in a separate isolate
  /// and returns the result asynchronously.
  ///
  /// If [enableProfiling] is true, profiling logs will be included for performance analysis.
  /// Throws a [TaskExecutionException] if the task fails.
  ///
  /// [operation] is the task to run in the background.
  /// [enableProfiling] enables profiling logs if true.
  static Future<T> runExpensiveOperation<T>(
    Future<T> Function() operation, {
    bool enableProfiling = false, // Enables profiling logs if true
  }) async {
    final startTime = DateTime.now();
    try {
      // Start profiling if enabled
      if (enableProfiling) {
        developer.log("Task started at: $startTime");
      }

      // Execute the operation
      final result = await _runOperation(operation);

      final endTime = DateTime.now();
      if (enableProfiling) {
        developer.log("Task completed in: ${endTime.difference(startTime)}");
      }

      return result;
    } catch (e, stackTrace) {
      developer.log('Error in background task: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Executes a computationally expensive [operation] with a timeout in a separate isolate.
  ///
  /// If [timeout] is provided, the operation will be cancelled if it exceeds the given time.
  /// If [enableProfiling] is true, profiling logs will be included for performance analysis.
  /// Throws a [TimeoutException] or [TaskExecutionException] if the operation times out or fails.
  static Future<T> runExpensiveOperationWithTimeout<T>(
    Future<T> Function() operation, {
    Duration? timeout, // The maximum time the operation is allowed to run
    bool enableProfiling = false, // Enables profiling logs if true
  }) async {
    final startTime = DateTime.now();
    try {
      // Start profiling if enabled
      if (enableProfiling) {
        developer.log("Task started at: $startTime");
      }

      // Execute the operation with timeout
      final result = await _runOperationWithTimeout(operation, timeout);

      final endTime = DateTime.now();
      if (enableProfiling) {
        developer.log("Task completed in: ${endTime.difference(startTime)}");
      }

      return result;
    } catch (e, stackTrace) {
      developer.log('Error in background task: $e', stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Executes a computationally expensive [operation] with retries, with an optional timeout.
  ///
  /// This method will retry the operation [retries] times if it fails, with a [retryDelay]
  /// between each retry attempt. Optionally, a [timeout] can be specified to limit the execution time.
  /// If [enableProfiling] is true, profiling logs will be included for performance analysis.
  /// Throws a [TaskExecutionException] if the operation fails after all retries.
  static Future<T> runExpensiveOperationWithRetry<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    int retries = 3,
    Duration retryDelay = const Duration(seconds: 2),
    bool enableProfiling = false,
  }) async {
    int attempt = 0;
    Duration backoffDelay = retryDelay;

    while (attempt < retries) {
      try {
        if (enableProfiling) {
          developer.log("Attempt #${attempt + 1} started");
        }

        // Execute the operation
        final result = await operation();

        if (enableProfiling) {
          developer.log("Attempt #${attempt + 1} succeeded");
        }

        return result;
      } catch (e, stackTrace) {
        attempt++;
        if (attempt >= retries) {
          if (enableProfiling) {
            developer.log("Task failed after $retries attempts");
          }
          // Wrap the error in a custom exception for better error reporting
          throw TaskExecutionException(
              'Operation failed after $retries retries', e, stackTrace);
        }

        if (enableProfiling) {
          developer.log("Attempt #$attempt failed, retrying...");
        }
        await Future.delayed(backoffDelay);
        backoffDelay *= 2; // Exponential backoff
      }
    }

    // In case retries are exhausted
    throw TaskExecutionException('Operation failed after $retries retries');
  }

  /// Internal method that executes the provided [operation] in an isolate.
  ///
  /// This method runs the operation in a separate isolate and waits for the result.
  /// It returns the result of the operation if successful, or throws an error if it fails.
  static Future<T> _runOperation<T>(Future<T> Function() operation) async {
    final receivePort = ReceivePort();
    Isolate? isolate;

    try {
      // Spawn a new isolate to perform the operation
      isolate = await Isolate.spawn(
        _executeOperation,
        [operation, receivePort.sendPort],
      );

      // Wait for the result
      final result = await receivePort.first;

      // Check if the result is an error message and throw an exception if so
      if (result is String && result.startsWith('error:')) {
        throw TaskExecutionException('Error during operation', result);
      }

      return result as T;
    } catch (e, stackTrace) {
      developer.log('Error in background task: $e', stackTrace: stackTrace);
      rethrow;
    } finally {
      receivePort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }

  /// Internal method that executes the provided [operation] in an isolate with timeout.
  ///
  /// This method runs the operation in a separate isolate, with the added ability to
  /// timeout the operation if it exceeds the specified [timeout].
  static Future<T> _runOperationWithTimeout<T>(
    Future<T> Function() operation,
    Duration? timeout,
  ) async {
    final receivePort = ReceivePort();
    Isolate? isolate;

    try {
      isolate = await Isolate.spawn(
        _executeOperation,
        [operation, receivePort.sendPort],
      );

      // Wait for the result with an optional timeout
      final result = timeout != null
          ? await receivePort.first.timeout(timeout, onTimeout: () {
              throw TimeoutException('The operation timed out');
            })
          : await receivePort.first;

      if (result is String && result.startsWith('error:')) {
        throw TaskExecutionException('Error during operation', result);
      }

      return result as T;
    } catch (e, stackTrace) {
      developer.log('Error in background task: $e', stackTrace: stackTrace);
      rethrow;
    } finally {
      receivePort.close();
      isolate?.kill(priority: Isolate.immediate);
    }
  }

  /// Internal method that executes the provided [operation] in an isolate.
  ///
  /// This method sends the result of the operation back through the [sendPort] when completed.
  static void _executeOperation(List<dynamic> args) async {
    final operation = args[0] as Future Function();
    final sendPort = args[1] as SendPort;

    try {
      final result = await operation();
      sendPort.send(result);
    } catch (e) {
      sendPort.send('error: $e');
    }
  }
}

/// A custom exception for task execution failures, providing more detailed information.
class TaskExecutionException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  TaskExecutionException(this.message, [this.cause, this.stackTrace]);

  @override
  String toString() {
    final causeMsg = cause != null ? ' Cause: $cause' : '';
    return '$message$causeMsg';
  }
}
