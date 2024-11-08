
# BackgroundTask Package

## Overview

BackgroundTask is a Dart package designed to execute resource-intensive operations in the background, preventing the main isolate from being blocked. By leveraging isolates, this package ensures that heavy tasks can run asynchronously without affecting the responsiveness of the user interface. It offers built-in support for performance profiling, configurable timeouts, and robust retry logic to handle transient failures.

With BackgroundTask, you can offload tasks such as data processing, API requests, and complex calculations to background isolates, while keeping your app’s UI responsive. The package also includes tools to monitor task performance, manage retries with exponential backoff, and handle exceptions gracefully.

## Features

- Execute expensive operations in a background isolate.
- Supports profiling for performance analysis.
- Handles timeouts with customizable duration.
- Implements retry logic with exponential backoff.
- Provides detailed error handling with custom exceptions.

## Installation

To use this package, add it to your `pubspec.yaml` file:

```yaml
dependencies:
  background_task: ^1.0.0
```

Then, run the following command to install the package:

```bash
dart pub get
```

## Usage

### 1. **Run an Expensive Operation**

To run a computationally expensive task in the background without worrying about blocking the main isolate, use `BackgroundTask.runExpensiveOperation`. This method accepts a callback function and returns a `Future<T>`.

```dart
import 'package:background_task/background_task.dart';

void main() async {
  try {
    final result = await BackgroundTask.runExpensiveOperation(() async {
      // Simulate a heavy computation
      await Future.delayed(Duration(seconds: 5));
      return 'Task Complete';
    });

    print(result); // Output: Task Complete
  } catch (e) {
    print('Task failed: $e');
  }
}
```

### 2. **Run an Expensive Operation with Timeout**

If you want to ensure that your task doesn't run indefinitely, you can specify a `timeout` duration. If the operation exceeds this duration, a `TimeoutException` will be thrown.

```dart
import 'package:background_task/background_task.dart';

void main() async {
  try {
    final result = await BackgroundTask.runExpensiveOperationWithTimeout(
      () async {
        await Future.delayed(Duration(seconds: 10)); // This exceeds the timeout
        return 'Task Complete';
      },
      timeout: Duration(seconds: 3), // Set timeout of 3 seconds
    );

    print(result); 
  } catch (e) {
    print('Task failed: $e'); // Expected to throw TimeoutException
  }
}
```

### 3. **Run an Expensive Operation with Retry Logic**

If your task is prone to failures, you can retry it multiple times with an optional delay between retries. The retry logic supports exponential backoff.

```dart
import 'package:background_task/background_task.dart';

void main() async {
  try {
    final result = await BackgroundTask.runExpensiveOperationWithRetry(
      () async {
        // Simulate a task that might fail
        if (DateTime.now().second % 2 == 0) {
          throw 'Temporary Failure';
        }
        return 'Task Complete';
      },
      retries: 5, // Retry up to 5 times
      retryDelay: Duration(seconds: 1), // Wait 1 second between retries
    );

    print(result); // Output: Task Complete
  } catch (e) {
    print('Task failed after retries: $e');
  }
}
```

### 4. **Parse Video to Base64**

You can use the `BackgroundTask` package to offload the task of converting a video file to base64 in the background. This is particularly useful when you need to send large media files over a network but want to avoid blocking the main thread.

```dart
import 'dart:convert';
import 'dart:io';
import 'package:background_task/background_task.dart';

void main() async {
  try {
    final videoPath = 'path/to/video.mp4';

    final base64String = await BackgroundTask.runExpensiveOperation(() async {
      final videoFile = File(videoPath);
      final bytes = await videoFile.readAsBytes();
      return base64Encode(bytes); // Convert video to base64 string
    });

    print('Base64 Video: $base64String'); // Base64 encoded video
  } catch (e) {
    print('Task failed: $e');
  }
}
```

### 5. **GET Request to a Server**

You can also use the `BackgroundTask` to perform HTTP requests without blocking the main thread. Here’s an example of making a GET request to an external server.

```dart
import 'package:http/http.dart' as http;
import 'package:background_task/background_task.dart';

void main() async {
  try {
    final response = await BackgroundTask.runExpensiveOperation(() async {
      final url = Uri.parse('https://api.example.com/data');
      final res = await http.get(url);

      if (res.statusCode == 200) {
        return res.body; // Response body from the server
      } else {
        throw 'Failed to load data: ${res.statusCode}';
      }
    });

    print('Server Response: $response'); // Print server response
  } catch (e) {
    print('Task failed: $e');
  }
}
```

## Parameters

- **enableProfiling**: If set to `true`, logs the start time, end time, and duration of the task for profiling and performance analysis.
- **timeout**: Sets a maximum duration for the operation. If the operation exceeds this time, a `TimeoutException` is thrown.
- **retries**: The number of retry attempts if the task fails.
- **retryDelay**: The delay between each retry attempt.
- **operation**: A callback function that performs the task you want to execute in the background.

## Error Handling

The package throws the following custom exceptions:
- **TaskExecutionException**: This exception is thrown when a background task fails or exceeds retry attempts. It includes a message with details of the failure.

```dart
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
```

## Use Cases

### Computationally Expensive Tasks
When performing tasks like data processing, image rendering, or network requests that require heavy computation, you can offload the operation to a background isolate to prevent blocking the main thread.

### Long-Running Operations
If you need to run a long operation, such as fetching data from a remote API, and want to ensure it doesn't time out or slow down your app's responsiveness, you can use the timeout functionality and handle retries automatically.

### Retry Logic
For tasks that may fail due to network issues or transient errors, use the retry functionality to automatically attempt the task multiple times with delays between attempts.

### Media Conversion (Base64)
When handling large media files, such as videos, converting them to Base64 format in the background allows you to send them over a network without affecting the responsiveness of the main UI thread.

### Networking (GET Requests)
You can also use background tasks to make HTTP requests to servers or external APIs without affecting the UI thread, ensuring smooth and responsive user experiences.

## Performance Considerations

- **Profiling**: If enabled, the profiling logs can help identify bottlenecks in long-running tasks.
- **Isolates**: The package uses Dart isolates, so the background tasks do not interfere with the main isolate, ensuring smooth UI performance.
- **Timeouts**: Always set reasonable timeouts for your operations, especially when working with external APIs or services that may be unreliable.

## Conclusion

The `BackgroundTask` package is designed to help manage expensive and long-running tasks by executing them in separate isolates. With built-in support for timeouts, retries, and profiling, this package helps you keep your application responsive and efficient.

## License

This package is open-source and available under the MIT license. See LICENSE for more details.

---

### Author: Ruben Orero Levy  
Email: rulevydeveloper@gmail.com  
Date: 08/11/2024  
