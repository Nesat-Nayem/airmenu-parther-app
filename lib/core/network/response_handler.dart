import 'dart:convert';
import 'dart:io';
import 'package:airmenuai_partner_app/core/network/data_error.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/utils/logger/Log.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class ResponseHandler {
  /// Extracts error message from API response body
  String _extractErrorMessage(String body, String fallback) {
    try {
      final json = jsonDecode(body);
      // Try common error message fields
      if (json is Map) {
        if (json['message'] != null && json['message'].toString().isNotEmpty) {
          return json['message'].toString();
        }
        if (json['error'] != null && json['error'].toString().isNotEmpty) {
          return json['error'].toString();
        }
        // Check errorMessages array
        if (json['errorMessages'] is List &&
            (json['errorMessages'] as List).isNotEmpty) {
          final firstError = json['errorMessages'][0];
          if (firstError is Map && firstError['message'] != null) {
            return firstError['message'].toString();
          }
        }
      }
    } catch (_) {
      // JSON parsing failed, return fallback
    }
    return fallback;
  }

  Future<DataState<T>> responseHandlerFun<T>({
    required Response response,
    required String urlPath,
    required T Function(String) fun,
    String? cacheKey,
    void Function(int)? statusCode,
  }) async {
    try {
      debugPrint("response.body ${response.body}");
      statusCode?.call(response.statusCode);

      if (response.statusCode >= 200 && response.statusCode <= 299) {
        debugPrint('$urlPath ($T)\'s API CALL SUCCESS');
        Log.info('Success API -> $urlPath');
        try {
          final data = fun(response.body);
          return DataSuccess<T>(data);
        } catch (e, s) {
          Log.error("Error parsing response: ${e.toString()}\nStack trace: $s");
          return DataFailure<T>(
            DataError(
              message: "Failed to parse response: ${e.toString()}",
              statusCode: response.statusCode,
            ),
          );
        }
      } else if (response.statusCode >= 300 && response.statusCode < 400) {
        final message = _extractErrorMessage(response.body, "Bad Request");
        Log.error("Bad Request - $urlPath: $message");
        return DataFailure<T>(
          DataError(message: message, statusCode: response.statusCode),
        );
      } else if (response.statusCode == 401) {
        final message = _extractErrorMessage(response.body, "Unauthorized");
        Log.error("Unauthorized API - $urlPath: $message");
        return DataFailure<T>(
          DataError(message: message, statusCode: response.statusCode),
        );
      } else if (response.statusCode > 401 && response.statusCode < 500) {
        final message = _extractErrorMessage(response.body, "Client Error");
        Log.error("Client Error - $urlPath: $message");
        return DataFailure<T>(
          DataError(message: message, statusCode: response.statusCode),
        );
      } else if (response.statusCode >= 500) {
        final message = _extractErrorMessage(response.body, "Server Error");
        Log.error("Server Error - $urlPath: $message");
        return DataFailure<T>(
          DataError(message: message, statusCode: response.statusCode),
        );
      } else {
        final message = _extractErrorMessage(response.body, "Unknown Error");
        Log.error("Unknown Error - $urlPath: $message");
        return DataFailure<T>(
          DataError(message: message, statusCode: response.statusCode),
        );
      }
    } on SocketException catch (e, s) {
      Log.error("SocketException - $urlPath: ${e.toString()}\nStack trace: $s");
      return DataFailure<T>(
        DataError(message: "No internet connection", statusCode: 0),
      );
    } on HttpException catch (e, s) {
      Log.error("HttpException - $urlPath: ${e.message}\nStack trace: $s");
      return DataFailure<T>(
        DataError(message: "HTTP Error: ${e.message}", statusCode: 0),
      );
    } on ClientException catch (e, s) {
      Log.error("ClientException - $urlPath: ${e.message}\nStack trace: $s");
      return DataFailure<T>(
        DataError(message: "Client Error: ${e.message}", statusCode: 0),
      );
    } on FormatException catch (e, s) {
      debugPrint('FormatException = ${response.body} $e');
      Log.error("FormatException - $urlPath: ${e.toString()}\nStack trace: $s");
      return DataFailure<T>(
        DataError(
          message: "Invalid data format",
          statusCode: response.statusCode,
        ),
      );
    } catch (e, s) {
      Log.error(
        "Unexpected Error - $urlPath: ${e.toString()}\nStack trace: $s",
      );
      return DataFailure<T>(
        DataError(message: "Unexpected error: ${e.toString()}", statusCode: 0),
      );
    }
  }
}
