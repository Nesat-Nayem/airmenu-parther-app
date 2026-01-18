import 'dart:convert';
import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/secure_storage.dart';

class UserService {
  final SecureStorage _secureStorage = locator<SecureStorage>();

  /// Save user data after login
  Future<void> saveUser(UserModel user) async {
    await _secureStorage.setString(
      key: SecureStorageKey.userData,
      value: jsonEncode(user.toJson()),
    );
  }

  /// Get current user data
  Future<UserModel?> getCurrentUser() async {
    final userDataString = await _secureStorage.getString(
      key: SecureStorageKey.userData,
    );

    if (userDataString == null || userDataString.isEmpty) {
      return null;
    }

    try {
      final userData = jsonDecode(userDataString) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      return null;
    }
  }

  /// Clear user data on logout
  Future<void> clearUser() async {
    await _secureStorage.remove(key: SecureStorageKey.userData);
  }
}

