import 'dart:async';

import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/config/router/root_navigator_key.dart';
import 'package:airmenuai_partner_app/core/network/auth_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/logger/log.dart';
import 'package:go_router/go_router.dart';

/// Central place to handle token-expired / unauthorized responses.
///
/// - Clears local auth state (token + cached user)
/// - Navigates to login route from anywhere (no BuildContext needed)
class SessionExpiryHandler {
  static bool _isHandling = false;

  static Future<void> forceLogoutToLogin({
    String reason = 'Session expired',
  }) async {
    if (_isHandling) return;
    _isHandling = true;

    try {
      Log.warning('🔒 Force logout triggered: $reason');
      await locator<AuthService>().logout();

      final ctx = rootNavigatorKey.currentContext;
      if (ctx != null) {
        // Replace current route stack with login.
        ctx.go(AppRoutes.loginAndSignUp.path);
      } else {
        Log.warning(
          'rootNavigatorKey.currentContext is null; will rely on router redirect',
        );
      }
    } catch (e, s) {
      Log.error('Force logout failed: $e\n$s');
    } finally {
      // Give navigation a moment; prevents rapid multi-call loops.
      unawaited(Future<void>.delayed(const Duration(milliseconds: 300)));
      _isHandling = false;
    }
  }
}

