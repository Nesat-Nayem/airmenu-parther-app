/// Model for promo code data with full null safety
/// Maps to the Coupon API (/coupon) response
class PromoCodeModel {
  final String id;
  final String code;
  final String discountType; // 'flat', 'percentage'
  final double discountValue;
  final double minOrder;
  final int uses;
  final int usageLimit;
  final String status; // 'active', 'paused'
  final bool isGlobal;
  final String? vendorId;
  final String? restaurantId;
  final DateTime? createdAt;
  final DateTime? validFrom;
  final DateTime? expiresAt;

  const PromoCodeModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    required this.uses,
    this.usageLimit = 0,
    required this.status,
    this.isGlobal = false,
    this.vendorId,
    this.restaurantId,
    this.createdAt,
    this.validFrom,
    this.expiresAt,
  });

  /// Factory constructor to map from Coupon API response
  factory PromoCodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PromoCodeModel.empty();

    return PromoCodeModel(
      id: (json['_id'] as String?) ?? (json['id'] as String?) ?? '',
      code: (json['couponCode'] as String?) ?? (json['code'] as String?) ?? '',
      discountType: 'percentage', // Coupon API uses percentage by default
      discountValue:
          (json['discountPercentage'] as num?)?.toDouble() ??
          (json['discountValue'] as num?)?.toDouble() ??
          0.0,
      minOrder:
          (json['minOrderAmount'] as num?)?.toDouble() ??
          (json['minOrder'] as num?)?.toDouble() ??
          0.0,
      uses: (json['totalUses'] as int?) ?? (json['uses'] as int?) ?? 0,
      usageLimit: (json['usageLimit'] as int?) ?? 0,
      status: _parseStatus(json['isActive']),
      isGlobal: (json['isGlobal'] as bool?) ?? false,
      vendorId: json['vendorId'] as String?,
      restaurantId: json['restaurantId'] as String?,
      createdAt: _parseDate(json['createdAt']),
      validFrom: _parseDate(json['validFrom']),
      expiresAt:
          _parseDate(json['validUntil']) ?? _parseDate(json['expiresAt']),
    );
  }

  /// Parse status from boolean isActive
  static String _parseStatus(dynamic isActive) {
    if (isActive == null) return 'active';
    if (isActive is bool) return isActive ? 'active' : 'paused';
    if (isActive is String) {
      return isActive.toLowerCase() == 'true' ? 'active' : 'paused';
    }
    return 'active';
  }

  /// Safe date parsing
  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Empty state factory
  factory PromoCodeModel.empty() {
    return const PromoCodeModel(
      id: '',
      code: '',
      discountType: 'percentage',
      discountValue: 0.0,
      minOrder: 0.0,
      uses: 0,
      status: 'active',
    );
  }

  /// Check if promo code has valid data
  bool get isValid => id.isNotEmpty && code.isNotEmpty;

  /// Check if promo code is active
  bool get isActive => status.toLowerCase() == 'active';

  /// Format discount for display (e.g., "₹50 off" or "20% off")
  String get discountDisplay {
    if (discountType == 'percentage') {
      return '${discountValue.toStringAsFixed(0)}% off';
    } else {
      return '₹${discountValue.toStringAsFixed(0)} off';
    }
  }

  /// Format min order for display
  String get minOrderDisplay {
    return '₹${minOrder.toStringAsFixed(0)}';
  }

  /// Format uses for display
  String get usesDisplay {
    if (uses >= 1000) {
      return '${(uses / 1000).toStringAsFixed(1)}K';
    }
    return uses.toString();
  }

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'couponCode': code,
      'discountPercentage': discountValue,
      'minOrderAmount': minOrder,
      'usageLimit': usageLimit,
      'isActive': isActive,
      'isGlobal': isGlobal,
      if (validFrom != null) 'validFrom': validFrom!.toIso8601String(),
      if (expiresAt != null) 'validUntil': expiresAt!.toIso8601String(),
    };
  }

  PromoCodeModel copyWith({
    String? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrder,
    int? uses,
    int? usageLimit,
    String? status,
    bool? isGlobal,
    String? vendorId,
    String? restaurantId,
    DateTime? createdAt,
    DateTime? validFrom,
    DateTime? expiresAt,
  }) {
    return PromoCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrder: minOrder ?? this.minOrder,
      uses: uses ?? this.uses,
      usageLimit: usageLimit ?? this.usageLimit,
      status: status ?? this.status,
      isGlobal: isGlobal ?? this.isGlobal,
      vendorId: vendorId ?? this.vendorId,
      restaurantId: restaurantId ?? this.restaurantId,
      createdAt: createdAt ?? this.createdAt,
      validFrom: validFrom ?? this.validFrom,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  String toString() {
    return 'PromoCodeModel(id: $id, code: $code, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PromoCodeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
