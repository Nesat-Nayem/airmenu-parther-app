import 'package:equatable/equatable.dart';

/// Staff role types for filtering
enum StaffRole { manager, headChef, kitchenStaff, waiter, cashier, delivery }

/// Work shift types
enum StaffShift { morning, evening, allDay }

/// Staff permissions model
class StaffPermissions extends Equatable {
  final bool orders;
  final bool menu;
  final bool inventory;
  final bool staff;
  final bool reports;
  final bool settings;

  const StaffPermissions({
    this.orders = false,
    this.menu = false,
    this.inventory = false,
    this.staff = false,
    this.reports = false,
    this.settings = false,
  });

  factory StaffPermissions.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const StaffPermissions();
    }
    return StaffPermissions(
      orders: json['orders'] as bool? ?? false,
      menu: json['menu'] as bool? ?? false,
      inventory: json['inventory'] as bool? ?? false,
      staff: json['staff'] as bool? ?? false,
      reports: json['reports'] as bool? ?? false,
      settings: json['settings'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orders': orders,
      'menu': menu,
      'inventory': inventory,
      'staff': staff,
      'reports': reports,
      'settings': settings,
    };
  }

  StaffPermissions copyWith({
    bool? orders,
    bool? menu,
    bool? inventory,
    bool? staff,
    bool? reports,
    bool? settings,
  }) {
    return StaffPermissions(
      orders: orders ?? this.orders,
      menu: menu ?? this.menu,
      inventory: inventory ?? this.inventory,
      staff: staff ?? this.staff,
      reports: reports ?? this.reports,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    menu,
    inventory,
    staff,
    reports,
    settings,
  ];
}

/// Staff member model
class StaffModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String hotelId;
  final String? hotelName;
  final String vendorId;
  final String status; // 'active' or 'inactive'

  // Fields from backend (currently missing, use placeholders)
  final String? staffRole; // "-" if not available from API
  final String? shift; // "-" if not available from API
  final StaffPermissions permissions;
  final DateTime? createdAt;

  const StaffModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.hotelId,
    this.hotelName,
    required this.vendorId,
    required this.status,
    this.staffRole,
    this.shift,
    this.permissions = const StaffPermissions(),
    this.createdAt,
  });

  /// Check if staff is active
  bool get isActive => status == 'active';

  /// Get display role - show "-" if role not available from API
  String get displayRole => staffRole ?? '-';

  /// Get display shift - show "-" if shift not available from API
  String get displayShift => shift ?? '-';

  /// Get formatted join date like "Since Jan 2024"
  String get joinedDisplay {
    if (createdAt == null) return '-';
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return 'Since ${months[createdAt!.month - 1]} ${createdAt!.year}';
  }

  /// Get initials for avatar
  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }

  factory StaffModel.fromJson(Map<String, dynamic> json) {
    // Parse hotelId - can be object or string
    String hotelId = '';
    String? hotelName;
    if (json['hotelId'] is Map) {
      hotelId = json['hotelId']['_id'] as String? ?? '';
      hotelName = json['hotelId']['name'] as String?;
    } else {
      hotelId = json['hotelId'] as String? ?? '';
    }

    // Parse createdAt
    DateTime? createdAt;
    if (json['createdAt'] != null) {
      try {
        createdAt = DateTime.parse(json['createdAt'] as String);
      } catch (_) {}
    }

    return StaffModel(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      hotelId: hotelId,
      hotelName: hotelName,
      vendorId: json['vendorId'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      // These fields are not yet in backend - will show "-"
      staffRole: json['staffRole'] as String?,
      shift: json['shift'] as String?,
      permissions: StaffPermissions.fromJson(
        json['permissions'] as Map<String, dynamic>?,
      ),
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'hotelId': hotelId,
      // These will be ignored by current backend but ready for future
      if (staffRole != null) 'staffRole': staffRole,
      if (shift != null) 'shift': shift,
      'permissions': permissions.toJson(),
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'status': status,
      if (staffRole != null) 'staffRole': staffRole,
      if (shift != null) 'shift': shift,
      'permissions': permissions.toJson(),
    };
  }

  StaffModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? hotelId,
    String? hotelName,
    String? vendorId,
    String? status,
    String? staffRole,
    String? shift,
    StaffPermissions? permissions,
    DateTime? createdAt,
  }) {
    return StaffModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      hotelId: hotelId ?? this.hotelId,
      hotelName: hotelName ?? this.hotelName,
      vendorId: vendorId ?? this.vendorId,
      status: status ?? this.status,
      staffRole: staffRole ?? this.staffRole,
      shift: shift ?? this.shift,
      permissions: permissions ?? this.permissions,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    hotelId,
    vendorId,
    status,
    staffRole,
    shift,
    permissions,
  ];
}
