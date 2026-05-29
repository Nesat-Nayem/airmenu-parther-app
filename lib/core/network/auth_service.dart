import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
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

  /// Re-fetch the authenticated user from the server and persist the fresh
  /// profile. This is how the app picks up server-side changes that happen
  /// after login — most importantly a vendor being approved by an admin
  /// (status flips to `active` and a restaurant/hotel gets created, so a
  /// `hotelId` becomes available). Without this, the cached profile from login
  /// is stale and vendor screens fail with "Restaurant ID not found".
  ///
  /// Returns the refreshed [UserModel], or null if the refresh failed (e.g. no
  /// token / network error). The cached profile is left untouched on failure.
  Future<UserModel?> refreshUserProfile() async {
    try {
      final response = await _apiService.invoke<Map<String, dynamic>>(
        urlPath: ApiEndpoints.me,
        type: RequestType.get,
        fun: (jsonString) => jsonDecode(jsonString) as Map<String, dynamic>,
      );

      if (response is DataSuccess<Map<String, dynamic>>) {
        final body = response.data;
        if (body != null && body['success'] == true && body['data'] != null) {
          final user = UserModel.fromJson(body['data'] as Map<String, dynamic>);
          await locator<UserService>().saveUser(user);

          // Keep the plain-prefs `hotelId` in sync — many vendor screens read
          // it directly from LocalStorage.
          final localStorage = locator<LocalStorage>();
          if (user.hotelId != null && user.hotelId!.isNotEmpty) {
            await localStorage.setString(
              localStorageKey: 'hotelId',
              value: user.hotelId!,
            );
          } else {
            await localStorage.remove(localStorageKey: 'hotelId');
          }

          debugPrint(
            '🔄 Profile refreshed: role=${user.role}, status=${user.status}, hotelId=${user.hotelId}',
          );
          return user;
        }
      }
      debugPrint('⚠️ Profile refresh did not return a usable user');
      return null;
    } catch (e) {
      debugPrint('❌ Profile refresh failed: $e');
      return null;
    }
  }

  Future<bool> _isValidToken(String? token) async {
    if (token == null || token.isEmpty) {
      return false;
    }
    return true;
  }
}
