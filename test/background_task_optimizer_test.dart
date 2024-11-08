// author: Ruben Orero Levy
// email: rulevydeveloper@gmail.com
// createdate:  08/11/2024
// ︻デ═一

import 'package:background_task_optimizer/background_task_optimizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';

void main() {
  group('BackgroundTask', () {
    // Test for a successful operation using runExpensiveOperation.
    test('runExpensiveOperation completes successfully', () async {
      // Simulates a successful operation that returns 42.
      final result = await BackgroundTask.runExpensiveOperation<int>(() async {
        return Future.value(42); // Returns a value of 42 after completion
      });

      // Verifies that the result is 42.
      expect(result, 42); // The result should be 42
    });

    // Test for runExpensiveOperationWithTimeout ensuring completion within the timeout.
    test('runExpensiveOperationWithTimeout completes within timeout', () async {
      // Simulates an operation that takes 50ms, which is within the 1-second timeout.
      final result = await BackgroundTask.runExpensiveOperationWithTimeout<int>(
        () async {
          await Future.delayed(Duration(milliseconds: 50)); // Waits 50ms
          return 42; // Returns 42 after delay
        },
        timeout: Duration(seconds: 1), // Timeout is set to 1 second
      );

      // Verifies that the result is 42.
      expect(result,
          42); // The result should be 42 as the operation completes on time
    });

    // Test for runExpensiveOperationWithTimeout to throw TimeoutException when exceeding timeout.
    test(
        'runExpensiveOperationWithTimeout throws TimeoutException if it exceeds timeout',
        () async {
      // Ensures that the operation throws a TimeoutException if it exceeds the timeout.
      expect(
        () => BackgroundTask.runExpensiveOperationWithTimeout<int>(
          () async {
            await Future.delayed(
                Duration(seconds: 2)); // Operation takes 2 seconds
            return 42; // Should not reach this point
          },
          timeout: Duration(milliseconds: 100), // Timeout is set to 100ms
        ),
        throwsA(
            isA<TimeoutException>()), // Expects a TimeoutException to be thrown
      );
    });

    // Test for runExpensiveOperationWithRetry, ensuring retries and eventual success.
    test('runExpensiveOperationWithRetry retries and eventually succeeds',
        () async {
      int attempt = 0;

      // Simulates an operation that fails twice and then succeeds on the third attempt.
      Future<int> operation() async {
        attempt++; // Increment the attempt counter
        if (attempt < 3) {
          throw Exception(
              'Simulated failure'); // Throws exception on first two attempts
        }
        return 42; // Returns 42 on the third attempt
      }

      // Calls the function with 3 retries, simulating retries on failures.
      final result = await BackgroundTask.runExpensiveOperationWithRetry<int>(
        operation,
        retries: 3, // Retry up to 3 times
        retryDelay: Duration(milliseconds: 100), // 100ms delay between retries
      );

      // Verifies that the result is 42 and that the operation attempted 3 times.
      expect(result, 42); // The result should be 42 after retries
      expect(attempt,
          3); // The operation should have attempted 3 times before succeeding
    });

    // Test for runExpensiveOperationWithRetry, ensuring failure after max retries.
    test('runExpensiveOperationWithRetry fails after max retries', () async {
      int attempt = 0;

      // Simulates an operation that always fails.
      Future<int> operation() async {
        attempt++; // Increment the attempt counter
        throw Exception('Simulated failure'); // Always throw an exception
      }

      try {
        // The operation will always fail in all attempts, so an exception should be thrown.
        await BackgroundTask.runExpensiveOperationWithRetry<int>(
          operation,
          retries: 3, // Retry up to 3 times
          retryDelay:
              Duration(milliseconds: 100), // 100ms delay between retries
        );
        fail(
            'Expected an exception to be thrown'); // Fails if no exception is thrown
      } catch (e) {
        // Verifies that the exception is correctly thrown after retries.
        expect(e,
            isA<TaskExecutionException>()); // Expects TaskExecutionException to be thrown
        expect(attempt,
            3); // The operation should have attempted 3 times before failing
      }
    });

    // Test for runExpensiveOperationWithRetry, ensuring it throws after max retries.
    test('runExpensiveOperationWithRetry throws after max retries', () async {
      // Verifies that the operation throws a TaskExecutionException after max retries.
      expect(
        () => BackgroundTask.runExpensiveOperationWithRetry<int>(
          () async {
            throw Exception('Failed attempt'); // Always fails
          },
          retries: 3, // Retry up to 3 times
          retryDelay:
              Duration(milliseconds: 100), // 100ms delay between retries
        ),
        throwsA(isA<
            TaskExecutionException>()), // Expects TaskExecutionException after retries
      );
    });

    // Test for runExpensiveOperation handling exceptions properly.
    test('runExpensiveOperation handles exceptions properly', () async {
      // Simulates an operation that throws an exception.
      expect(
        () async => await BackgroundTask.runExpensiveOperation<int>(() async {
          throw Exception('Test exception'); // Throws a test exception
        }),
        throwsA(isA<TaskExecutionException>().having(
            (e) => e.cause.toString(), 'cause', contains('Test exception'))),
      );
    });

    // Test for runExpensiveOperationWithRetry, ensuring no retries if operation succeeds.
    test('runExpensiveOperationWithRetry does not retry if operation succeeds',
        () async {
      int attempt = 0;

      // Simulates an operation that always succeeds on the first attempt.
      Future<int> operation() async {
        attempt++; // Increment the attempt counter
        return 42; // Returns 42 immediately on the first attempt
      }

      // Calls the function with 3 retries, but the operation succeeds on the first try.
      final result = await BackgroundTask.runExpensiveOperationWithRetry<int>(
        operation,
        retries: 3, // Retry up to 3 times
        retryDelay: Duration(milliseconds: 100), // 100ms delay between retries
      );

      // Verifies that the result is 42 and that the operation only attempted once.
      expect(result,
          42); // The result should be 42 as the operation succeeds on the first attempt
      expect(attempt,
          1); // It should have only attempted once since it succeeded immediately
    });
  });
}
