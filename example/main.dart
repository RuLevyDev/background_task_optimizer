import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:background_task_optimizer/background_task_optimizer.dart';

void main() async {
  await runBasicTask();
  await runTaskWithTimeout();
  await runTaskWithRetry();
  await parseVideoToBase64();
  //to perform performGetRequest(); you need package such as http
  //await performGetRequest();
}

/// 1️⃣ Runs an expensive operation in a background isolate.
Future<void> runBasicTask() async {
  try {
    final result = await BackgroundTask.runExpensiveOperation(() async {
      await Future.delayed(Duration(seconds: 2));
      return '✅ Task completed';
    });

    print(result);
  } catch (e) {
    print('❌ Task error: $e');
  }
}

/// 2️⃣ Runs a task with a defined timeout.
Future<void> runTaskWithTimeout() async {
  try {
    final result = await BackgroundTask.runExpensiveOperationWithTimeout(
      () async {
        await Future.delayed(Duration(seconds: 5));
        return '✅ Task completed within time';
      },
      timeout: Duration(seconds: 3),
    );

    print(result);
  } catch (e) {
    print('⏳ Task failed due to timeout: $e');
  }
}

/// 3️⃣ Runs a task with automatic retries in case of failure.
Future<void> runTaskWithRetry() async {
  try {
    final result = await BackgroundTask.runExpensiveOperationWithRetry(
      () async {
        if (DateTime.now().second % 2 == 0) {
          throw '⚠️ Temporary failure';
        }
        return '✅ Task completed after retries';
      },
      retries: 3,
      retryDelay: Duration(seconds: 1),
    );

    print(result);
  } catch (e) {
    print('❌ Task failed after multiple attempts: $e');
  }
}

/// 4️⃣ Converts a video file to Base64 in the background.
Future<void> parseVideoToBase64() async {
  try {
    final videoPath = 'path/to/video.mp4';

    final base64String = await BackgroundTask.runExpensiveOperation(() async {
      final videoFile = File(videoPath);
      final bytes = await videoFile.readAsBytes();
      return base64Encode(bytes);
    });

    print(
        '🎥 Base64 Video: ${base64String.substring(0, 50)}...'); // Truncate output
  } catch (e) {
    print('❌ Error converting to Base64: $e');
  }
}

/// 5️⃣ Performs a GET request to a server in the background.
//Future<void> performGetRequest() async {
 // try {
   // final response = await BackgroundTask.runExpensiveOperation(() async {
   //   final url = Uri.parse('https://api.example.com/data');
   //   final res = await http.get(url);

    // if (res.statusCode == 200) {
    //    return res.body;
    // } else {
    //   throw '❌ Request error: ${res.statusCode}';
    //  }
    //});

   // print('🌍 Server response: $response');
  //} catch (e) {
 //   print('❌ GET request failed: $e');
 //}
//}
