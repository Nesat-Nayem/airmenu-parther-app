/// Model for promo code data with full null safety
class PromoCodeModel {
  final String id;
  final String code;
  final String discountType; // 'flat', 'percentage'
  final double discountValue;
  final double minOrder;
  final int uses;
  final String status; // 'active', 'paused'
  final DateTime? createdAt;
  final DateTime? expiresAt;

  const PromoCodeModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrder,
    required this.uses,
    required this.status,
    this.createdAt,
    this.expiresAt,
  });

  /// Factory constructor with comprehensive null handling
  factory PromoCodeModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return PromoCodeModel.empty();

    return PromoCodeModel(
      id: (json['id'] as String?) ?? '',
      code: (json['code'] as String?) ?? '',
      discountType: _parseDiscountType(json['discountType']),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      minOrder: (json['minOrder'] as num?)?.toDouble() ?? 0.0,
      uses: (json['uses'] as int?) ?? 0,
      status: _parseStatus(json['status']),
      createdAt: _parseDate(json['createdAt']),
      expiresAt: _parseDate(json['expiresAt']),
    );
  }

  /// Parse discount type with fallback
  static String _parseDiscountType(dynamic type) {
    final validTypes = ['flat', 'percentage'];
    final typeStr = (type as String?) ?? 'flat';
    return validTypes.contains(typeStr.toLowerCase())
        ? typeStr.toLowerCase()
        : 'flat';
  }

  /// Parse status with fallback
  static String _parseStatus(dynamic status) {
    final validStatuses = ['active', 'paused'];
    final statusStr = (status as String?) ?? 'active';
    return validStatuses.contains(statusStr.toLowerCase())
        ? statusStr.toLowerCase()
        : 'active';
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
      discountType: 'flat',
      discountValue: 0.0,
      minOrder: 0.0,
      uses: 0,
      status: 'active',
      createdAt: null,
      expiresAt: null,
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discountType': discountType,
      'discountValue': discountValue,
      'minOrder': minOrder,
      'uses': uses,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  PromoCodeModel copyWith({
    String? id,
    String? code,
    String? discountType,
    double? discountValue,
    double? minOrder,
    int? uses,
    String? status,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return PromoCodeModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrder: minOrder ?? this.minOrder,
      uses: uses ?? this.uses,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
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
