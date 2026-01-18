import 'dart:developer' as dev;
import 'package:flutter/foundation.dart';

/// A utility class for standardized logging across the application.
/// It uses 'dev.log' which is superior to 'print' in Flutter for structured output,
/// especially in IDE consoles.
class Log {
  // Define a consistent tag or prefix for all log messages
  static const String _logTag = '[AirMenuAI]';

  // ==============================
  // 1. INFO LOGGING
  // ==============================
  /// Logs a standard informational message.
  static void info(String message) {
    // Only log INFO in debug mode for production performance.
    if (kDebugMode) {
      final now = DateTime.now().toIso8601String();
      dev.log('ℹ️ $now $_logTag INFO: $message');
    }
  }

  // ==============================
  // 2. ERROR LOGGING
  // ==============================
  /// Logs an error, typically used for API failures or exceptions.
  ///
  /// The 'apiError' parameter can be a String (for a simple message)
  /// or an actual Exception/Error object.
  static void error(dynamic apiError) {
    final now = DateTime.now().toIso8601String();

    // Convert the error to a readable string, handling different input types
    String errorMessage;
    if (apiError is String) {
      errorMessage = apiError;
    } else if (apiError is Exception || apiError is Error) {
      errorMessage = apiError.toString();
    } else {
      errorMessage = 'Unknown error type: ${apiError.runtimeType}';
    }

    // Use a high-priority logging mechanism (dev.log or print)
    if (kDebugMode) {
      dev.log(
        '❌ $now $_logTag ERROR: $errorMessage',
        level: 2000,
      ); // Higher level for visibility
    } else {
      // In release mode, you might still want to capture errors
      // using a service like Sentry or Firebase Crashlytics.
      // FirebaseCrashlytics.instance.recordError(apiError, StackTrace.current);

      // For now, we'll just print to ensure it's captured in release environments
      // if not using a crash reporter.
      print('❌ $now $_logTag RELEASE ERROR: $errorMessage');
    }
  }

  // ==============================
  // 3. DEBUG LOGGING (Optional but highly recommended)
  // ==============================
  /// Logs messages intended for debugging only.
  static void debug(String message) {
    if (kDebugMode) {
      final now = DateTime.now().toIso8601String();
      dev.log('🐛 $now $_logTag DEBUG: $message');
    }
  }

  static void warning(dynamic message) {
    if (kDebugMode) {
      final now = DateTime.now().toIso8601String();
      dev.log('⚠️ $now $_logTag WARNING: $message');
    }
  }
}
