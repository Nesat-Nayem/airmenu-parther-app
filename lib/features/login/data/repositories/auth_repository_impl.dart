import 'dart:convert';
import 'package:airmenuai_partner_app/config/environment/env_config.dart';
import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/secure_storage.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_endpoints.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl extends AuthRepository {
  final SecureStorage _secureStorage = locator<SecureStorage>();
  final UserService _userService = locator<UserService>();

  @override
  Future<Either<String, bool>> login(String email, String password) async {
    try {
      // Use direct HTTP call to avoid CORS issues and match original endpoint
      final response = await http.post(
        Uri.parse(EnvConfig.apiUrl + ApiEndpoints.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse response
        final responseData = jsonDecode(response.body);

        // Save access token - check multiple possible field names
        String? token;
        if (responseData != null) {
          token =
              responseData['access_token'] ??
              responseData['token'] ??
              responseData['accessToken'] ??
              responseData['data']?['access_token'] ??
              responseData['data']?['token'];
        }

        if (token != null && token.isNotEmpty) {
          await _secureStorage.setString(
            key: SecureStorageKey.accessToken,
            value: token,
          );
          debugPrint('✅ Token saved successfully (length: ${token.length})');

          // Verify token was saved immediately
          final savedToken = await _secureStorage.getString(
            key: SecureStorageKey.accessToken,
          );
          if (savedToken != null && savedToken.isNotEmpty) {
            debugPrint('✅ Token verification: SUCCESS');
          } else {
            debugPrint(
              '❌ Token verification: FAILED - Token not found after save',
            );
          }
        } else {
          debugPrint('❌ No token found in response');
        }

        // Parse and save user data
        if (responseData != null && responseData['data'] != null) {
          try {
            final userData = responseData['data'] as Map<String, dynamic>;
            final user = UserModel.fromJson(userData);
            await _userService.saveUser(user);
          } catch (e) {
            // Log error but don't fail login if user data parsing fails
            print('Error parsing user data: $e');
          }
        }

        return const Right(true);
      } else {
        final body = jsonDecode(response.body);
        return Left(body['message'] ?? 'Login failed');
      }
    } catch (e) {
      return Left(e.toString());
    }
  }
}
