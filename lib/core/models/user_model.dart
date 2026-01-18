import 'package:airmenuai_partner_app/core/enums/user_role.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? img;
  final String status;
  final Map<String, dynamic>? subscription;
  final List<dynamic>? packageFeatures;
  final bool? trialActive;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.img,
    required this.status,
    this.subscription,
    this.packageFeatures,
    this.trialActive,
  });

  /// Get role as enum for easy comparison
  /// Usage: if (user.roleEnum == UserRole.admin) { ... }
  UserRole get roleEnum => UserRole.fromString(role);

  /// Helper methods for role checking
  bool get isVendor => roleEnum == UserRole.vendor;
  bool get isAdmin => roleEnum == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? '',
      img: json['img'],
      status: json['status'] ?? '',
      subscription: json['subscription'],
      packageFeatures: json['packageFeatures'],
      trialActive: json['trialActive'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'img': img,
      'status': status,
      'subscription': subscription,
      'packageFeatures': packageFeatures,
      'trialActive': trialActive,
    };
  }
}
