import 'dart:async';
import 'dart:convert';
import 'package:airmenuai_partner_app/config/environment/env_config.dart';
import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/core/network/data_error.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/core/network/response_handler.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../utils/logger/Log.dart' show Log;

abstract class DataService {
  Future<dynamic> invoke<T>({
    String urlBase,
    required String urlPath,
    required T Function(String) fun,
    required RequestType type,
    dynamic params,
    Map<String, String>? headers,
    String? cacheKey,
    void Function(int)? statusCode,
  });

  Future<dynamic> invokeMultipart<T>({
    String urlBase,
    required String urlPath,
    required T Function(String) fun,
    required RequestType type,
    required Map<String, String> fields,
    required Map<String, String> files,
    Map<String, String>? headers,
    void Function(int)? statusCode,
  });
}

class ApiService implements DataService {
  final ResponseHandler responseHandler = locator<ResponseHandler>();

  @override
  Future<dynamic> invoke<T>({
    String urlBase = EnvConfig.apiUrl,
    required String urlPath,
    required T Function(String) fun,
    required RequestType type,
    dynamic params,
    Map<String, String>? headers,
    String? cacheKey,
    void Function(int)? statusCode,
  }) async {
    /// [Headers]
    // Automatically add token to all requests
    final token = await locator<AuthService>().getAccessToken();

    // Initialize headers if not provided
    headers ??= {};

    // Always set Content-Type
    headers["Content-Type"] = "application/json";

    // Add Authorization header if token exists (don't override if already set)
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      Log.info("Token added to request: $urlPath");
    } else {
      Log.warning("Access Token is empty or null for request: $urlPath");
      // Don't add Authorization header if token is missing
      if (!headers.containsKey("Authorization")) {
        Log.error("No Authorization header will be sent for: $urlPath");
      }
    }

    /// [URLs]
    String url = urlPath.startsWith('/')
        ? "$urlBase$urlPath"
        : "$urlBase/$urlPath";

    Log.info("apiCall Initiated ${type.name} $url");
    try {
      const durationTimeout = Duration(minutes: 1);
      switch (type) {
        /// [GET]
        case RequestType.get:
          var uri = Uri.parse(url);
          final response = await http
              .get(uri, headers: headers)
              .timeout(durationTimeout);
          Log.info("apiResponse ${type.name} $url ${response.statusCode}");
          return await responseHandler.responseHandlerFun<T>(
            response: response,
            urlPath: urlPath,
            fun: fun,
            cacheKey: cacheKey,
            statusCode: statusCode,
          );

        /// [POST]
        case RequestType.post:
          var uri = Uri.parse(url);
          final response = await http
              .post(uri, body: jsonEncode(params), headers: headers)
              .timeout(durationTimeout);
          Log.info("apiResponse ${type.name} $url ${response.statusCode}");

          return await responseHandler.responseHandlerFun<T>(
            response: response,
            urlPath: urlPath,
            fun: fun,
            cacheKey: cacheKey,
            statusCode: statusCode,
          );
        case RequestType.patch:
          var uri = Uri.parse(url);
          final response = await http
              .patch(uri, body: jsonEncode(params), headers: headers)
              .timeout(durationTimeout);
          Log.info("apiResponse ${type.name} $url ${response.statusCode}");

          return await responseHandler.responseHandlerFun<T>(
            response: response,
            urlPath: urlPath,
            fun: fun,
            cacheKey: cacheKey,
            statusCode: statusCode,
          );
        case RequestType.put:
          var uri = Uri.parse(url);
          final response = await http
              .put(uri, body: jsonEncode(params), headers: headers)
              .timeout(durationTimeout);
          Log.info("apiResponse ${type.name} $url ${response.statusCode}");

          return await responseHandler.responseHandlerFun<T>(
            response: response,
            urlPath: urlPath,
            fun: fun,
            cacheKey: cacheKey,
            statusCode: statusCode,
          );
        case RequestType.delete:
          var uri = Uri.parse(url);
          final response = await http
              .delete(uri, body: jsonEncode(params), headers: headers)
              .timeout(durationTimeout);
          Log.info("apiResponse ${type.name} $url ${response.statusCode}");

          return await responseHandler.responseHandlerFun<T>(
            response: response,
            urlPath: urlPath,
            fun: fun,
            cacheKey: cacheKey,
            statusCode: statusCode,
          );
      }
    } on TimeoutException catch (e, s) {
      Log.error("Timeout - $urlPath: ${e.toString()}\\nStack trace: $s");
      return DataFailure<T>(
        DataError(message: "Request timeout", statusCode: 0),
      );
    } catch (e, s) {
      Log.error(
        "Unexpected error in ApiService - $urlPath: ${e.toString()}\\nStack trace: $s",
      );
      return DataFailure<T>(
        DataError(message: "Unexpected error: ${e.toString()}", statusCode: 0),
      );
    }
  }

  @override
  Future<dynamic> invokeMultipart<T>({
    String urlBase = EnvConfig.apiUrl,
    required String urlPath,
    required T Function(String) fun,
    required RequestType type,
    required Map<String, String> fields,
    required Map<String, String> files,
    Map<String, String>? headers,
    void Function(int)? statusCode,
  }) async {
    /// [Headers]
    final token = await locator<AuthService>().getAccessToken();
    headers ??= {};

    // Add Authorization header if token exists
    if (token != null && token.isNotEmpty) {
      headers["Authorization"] = "Bearer $token";
      Log.info("Token added to multipart request: $urlPath");
    }

    /// [URLs]
    String url = urlPath.startsWith('/')
        ? "$urlBase$urlPath"
        : "$urlBase/$urlPath";

    Log.info("apiCall Multipart Initiated ${type.name} $url");

    try {
      const durationTimeout = Duration(minutes: 2);
      var uri = Uri.parse(url);
      var request = http.MultipartRequest(type.name.toUpperCase(), uri);

      // Add headers
      request.headers.addAll(headers);

      // Add fields
      request.fields.addAll(fields);

      // Add files - handle web vs mobile differently
      for (var entry in files.entries) {
        if (kIsWeb) {
          // On web, we need to use fromBytes
          // The path is actually a blob URL from image picker
          final bytes = await http.readBytes(Uri.parse(entry.value));
          request.files.add(
            http.MultipartFile.fromBytes(
              entry.key,
              bytes,
              filename: 'upload.jpg',
            ),
          );
        } else {
          // On mobile/desktop, use fromPath
          request.files.add(
            await http.MultipartFile.fromPath(entry.key, entry.value),
          );
        }
      }

      // Send request
      final streamedResponse = await request.send().timeout(durationTimeout);
      final response = await http.Response.fromStream(streamedResponse);

      Log.info(
        "apiResponse Multipart ${type.name} $url ${response.statusCode}",
      );

      return await responseHandler.responseHandlerFun<T>(
        response: response,
        urlPath: urlPath,
        fun: fun,
        statusCode: statusCode,
      );
    } on TimeoutException catch (e, s) {
      Log.error("Timeout - $urlPath: ${e.toString()}\\nStack trace: $s");
      return DataFailure<T>(
        DataError(message: "Request timeout", statusCode: 0),
      );
    } catch (e, s) {
      Log.error(
        "Unexpected error in ApiService multipart - $urlPath: ${e.toString()}\\nStack trace: $s",
      );
      return DataFailure<T>(
        DataError(message: "Unexpected error: ${e.toString()}", statusCode: 0),
      );
    }
  }
}
