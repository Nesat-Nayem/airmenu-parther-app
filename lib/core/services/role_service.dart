import 'package:airmenuai_partner_app/core/enums/user_role.dart';
import 'package:airmenuai_partner_app/core/models/user_model.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';

/// Simple service to get current user's role
/// Usage: final role = await RoleService.getUserRole();
///        if (role == UserRole.admin) { ... }
class RoleService {
  static final UserService _userService = locator<UserService>();

  /// Get current user's role as enum
  /// Returns null if no user is logged in
  static Future<UserRole?> getUserRole() async {
    final user = await _userService.getCurrentUser();
    if (user == null) return null;

    return UserRole.fromString(user.role);
  }

  /// Check if current user has specific role
  /// Usage: if (await RoleService.hasRole(UserRole.admin)) { ... }
  static Future<bool> hasRole(UserRole role) async {
    final userRole = await getUserRole();
    return userRole == role;
  }

  /// Check if current user has any of the specified roles
  /// Usage: if (await RoleService.hasAnyRole([UserRole.admin, UserRole.superAdmin])) { ... }
  static Future<bool> hasAnyRole(List<UserRole> roles) async {
    final userRole = await getUserRole();
    if (userRole == null) return false;

    return roles.contains(userRole);
  }

  /// Get current user data
  static Future<UserModel?> getCurrentUser() async {
    return await _userService.getCurrentUser();
  }
}
