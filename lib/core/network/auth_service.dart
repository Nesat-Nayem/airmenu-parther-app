import 'dart:convert';
import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/secure_storage.dart';
import 'package:flutter/material.dart';

class AuthService {
  final ApiService _apiService = locator<ApiService>();
  final SecureStorage _secureStorage = locator<SecureStorage>();

  Future<bool> login(String email, String password) async {
    try {
      final params = {"email": email, "password": password};

      final response = await _apiService.invoke<Map<String, dynamic>>(
        urlPath: '/auth/signin',
        type: RequestType.post,
        params: params,
        fun: (jsonString) {
          final json = jsonDecode(jsonString);
          return json as Map<String, dynamic>;
        },
      );

      if (response is DataSuccess<Map<String, dynamic>>) {
        final responseData = response.data;
        if (responseData != null && responseData['success'] == true) {
          // Save token
          final token = responseData['token'];
          if (token != null) {
            await _secureStorage.setString(
              key: SecureStorageKey.accessToken,
              value: token.toString(),
            );
          }

          // Save user data
          final userData = responseData['data'];
          if (userData != null) {
            final user = UserModel.fromJson(userData);
            await locator<UserService>().saveUser(user);
            debugPrint('User saved: ${user.id} - ${user.name} - ${user.role}');
          }

          return true;
        }
      }
      return false;
    } catch (e) {
      debugPrint("Login failed: $e");
      return false;
    }
  }

  Future<void> logout() async {
    await _secureStorage.remove(key: SecureStorageKey.accessToken);
    // Clear user data on logout
    final userService = locator<UserService>();
    await userService.clearUser();
  }

  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getString(
      key: SecureStorageKey.accessToken,
    );

    if (token == null || token.isEmpty) {
      return false;
    }

    // Check if we have valid user data stored
    final user = await locator<UserService>().getCurrentUser();
    return user != null && user.id.isNotEmpty;
  }

  /// Returns access token for API calls
  Future<String?> getAccessToken() async {
    final accessToken = await _secureStorage.getString(
      key: SecureStorageKey.accessToken,
    );
    if (await _isValidToken(accessToken)) {
      return accessToken;
    }
    return null;
  }

  /// Get current user ID
  Future<String?> getCurrentUserId() async {
    final user = await locator<UserService>().getCurrentUser();
    return user?.id;
  }

  Future<bool> _isValidToken(String? token) async {
    if (token == null || token.isEmpty) {
      return false;
    }
    return true;
  }
}
