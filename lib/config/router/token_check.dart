import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/secure_storage.dart';
import 'package:flutter/foundation.dart';

/// Quick token check - just verifies token exists (for router redirects)
Future<bool> tokenCheck() async {
  try {
    final secureStorage = locator<SecureStorage>();
    final token = await secureStorage.getString(
      key: SecureStorageKey.accessToken,
    );
    // Just check if token exists, don't validate with API call
    // This is faster and prevents issues during login navigation
    final hasToken = token != null && token.isNotEmpty;
    if (kDebugMode) {
      debugPrint(
        '🔐 Token check: $hasToken (token: ${token != null ? "${token.substring(0, token.length > 20 ? 20 : token.length)}..." : "null"})',
      );
    }
    return hasToken;
  } catch (e) {
    if (kDebugMode) {
      debugPrint('❌ Token check error: $e');
    }
    return false;
  }
}

/// Full authentication check - validates token with API (for protected operations)
Future<bool> isAuthenticated() async {
  try {
    final authService = locator<AuthService>();
    return await authService.isAuthenticated();
  } catch (e) {
    return false;
  }
}

List<String> get isAuth => validateURL;
List<String> validateURL = [AppRoutes.loginAndSignUp.path];
