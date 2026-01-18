enum UserRole {
  vendor,
  admin;

  /// Convert string from API to UserRole enum
  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'vendor':
        return UserRole.vendor;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.vendor;
    }
  }

  /// Display name for UI
  String get displayName {
    switch (this) {
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.admin:
        return 'Admin';
    }
  }
}
