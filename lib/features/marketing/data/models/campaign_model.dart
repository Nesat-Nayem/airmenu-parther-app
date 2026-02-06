/// Model for campaign data with full null safety
class CampaignModel {
  final String id;
  final String name;
  final String type; // 'discount', 'promo', 'delivery'
  final String status; // 'active', 'scheduled', 'ended'
  final DateTime? startDate;
  final DateTime? endDate;
  final int reach;
  final int clicks;
  final int orders;
  final double revenue;
  final int restaurantCount;

  // Offer-specific fields for hotel-offers API
  final String? description;
  final String discountType; // 'percentage' or 'flat'
  final double discountValue;
  final double minOrderValue;
  final double? maxDiscount;
  final String offerType; // 'restaurant' or 'item'
  final List<String> validDays;
  final String validTimeStart;
  final String validTimeEnd;
  final int? usageLimit;

  const CampaignModel({
    required this.id,
    required this.name,
    required this.type,
    required this.status,
    this.startDate,
    this.endDate,
    required this.reach,
    required this.clicks,
    required this.orders,
    required this.revenue,
    required this.restaurantCount,
    this.description,
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.minOrderValue = 0,
    this.maxDiscount,
    this.offerType = 'restaurant',
    this.validDays = const [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ],
    this.validTimeStart = '00:00',
    this.validTimeEnd = '23:59',
    this.usageLimit,
  });

  /// Factory constructor with comprehensive null handling
  factory CampaignModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return CampaignModel.empty();

    return CampaignModel(
      id: (json['id'] as String?) ?? '',
      name: (json['name'] as String?) ?? 'Unnamed Campaign',
      type: _parseType(json['type']),
      status: _parseStatus(json['status']),
      startDate: _parseDate(json['startDate']),
      endDate: _parseDate(json['endDate']),
      reach: (json['reach'] as int?) ?? 0,
      clicks: (json['clicks'] as int?) ?? 0,
      orders: (json['orders'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      restaurantCount: (json['restaurantCount'] as int?) ?? 0,
    );
  }

  /// Parse type with fallback
  static String _parseType(dynamic type) {
    final validTypes = ['discount', 'promo', 'delivery'];
    final typeStr = (type as String?) ?? 'discount';
    return validTypes.contains(typeStr.toLowerCase())
        ? typeStr.toLowerCase()
        : 'discount';
  }

  /// Parse status with fallback
  static String _parseStatus(dynamic status) {
    final validStatuses = ['active', 'scheduled', 'ended'];
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
  factory CampaignModel.empty() {
    return const CampaignModel(
      id: '',
      name: '',
      type: 'discount',
      status: 'active',
      startDate: null,
      endDate: null,
      reach: 0,
      clicks: 0,
      orders: 0,
      revenue: 0.0,
      restaurantCount: 0,
    );
  }

  /// Factory constructor to map from hotel-offers API response
  factory CampaignModel.fromOfferJson(Map<String, dynamic>? json) {
    if (json == null) return CampaignModel.empty();

    // Determine status based on isActive and dates
    String status = 'active';
    final isActive = json['isActive'] as bool? ?? true;
    final endDate = _parseDate(json['validDateEnd']);

    if (!isActive) {
      status = 'ended';
    } else if (endDate != null && endDate.isBefore(DateTime.now())) {
      status = 'ended';
    } else {
      final startDate = _parseDate(json['validDateStart']);
      if (startDate != null && startDate.isAfter(DateTime.now())) {
        status = 'scheduled';
      }
    }

    // Map discountType to type
    String type = 'discount';
    final discountType = json['discountType'] as String? ?? '';
    if (discountType == 'percentage') {
      type = 'promo';
    } else if (json['offerType'] == 'delivery') {
      type = 'delivery';
    }

    // Parse validDays
    List<String> parsedDays = const [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    if (json['validDays'] != null && json['validDays'] is List) {
      parsedDays = (json['validDays'] as List)
          .map((e) => e.toString().toLowerCase())
          .toList();
    }

    return CampaignModel(
      id: (json['_id'] as String?) ?? (json['id'] as String?) ?? '',
      name: (json['title'] as String?) ?? 'Unnamed Offer',
      type: type,
      status: status,
      startDate: _parseDate(json['validDateStart']),
      endDate: _parseDate(json['validDateEnd']),
      reach:
          (json['usedCount'] as int?) ?? 0, // Using usedCount as reach for now
      clicks: 0, // Not available in API
      orders: (json['usedCount'] as int?) ?? 0,
      revenue: 0.0, // Not available in API
      restaurantCount: 1, // Single restaurant
      // Offer-specific fields
      description: json['description'] as String?,
      discountType: discountType.isNotEmpty ? discountType : 'percentage',
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0,
      minOrderValue: (json['minimumOrderValue'] as num?)?.toDouble() ?? 0,
      maxDiscount: (json['maximumDiscountAmount'] as num?)?.toDouble(),
      offerType: (json['offerType'] as String?) ?? 'restaurant',
      validDays: parsedDays,
      validTimeStart: (json['validTimeStart'] as String?) ?? '00:00',
      validTimeEnd: (json['validTimeEnd'] as String?) ?? '23:59',
      usageLimit: json['usageLimit'] as int?,
    );
  }

  /// Convert to hotel-offers API format for create/update
  Map<String, dynamic> toOfferJson(String? hotelId) {
    return {
      'title': name,
      'description': description ?? name,
      'discountType': discountType,
      'discountValue': discountValue,
      'offerType': offerType,
      'validDays': validDays,
      'validTimeStart': validTimeStart,
      'validTimeEnd': validTimeEnd,
      'validDateStart':
          startDate?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'validDateEnd':
          endDate?.toIso8601String() ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'minimumOrderValue': minOrderValue,
      if (maxDiscount != null) 'maximumDiscountAmount': maxDiscount,
      if (usageLimit != null) 'usageLimit': usageLimit,
      if (hotelId != null) 'hotelId': hotelId,
    };
  }

  /// Check if campaign has valid data
  bool get isValid => id.isNotEmpty && name.isNotEmpty;

  /// Format reach for display (e.g., 45.2K)
  String get formattedReach {
    if (reach >= 1000000) {
      return '${(reach / 1000000).toStringAsFixed(1)}M';
    } else if (reach >= 1000) {
      return '${(reach / 1000).toStringAsFixed(1)}K';
    }
    return reach.toString();
  }

  /// Format revenue for display (e.g., ₹2,34,000)
  String get formattedRevenue {
    if (revenue >= 100000) {
      return '₹${(revenue / 100000).toStringAsFixed(2)}L';
    } else if (revenue >= 1000) {
      // Indian numeral formatting
      final revenueInt = revenue.toInt();
      return '₹${_formatIndianNumber(revenueInt)}';
    }
    return '₹${revenue.toInt()}';
  }

  /// Format number in Indian style (1,23,456)
  static String _formatIndianNumber(int number) {
    final numStr = number.toString();
    if (numStr.length <= 3) return numStr;

    final result = StringBuffer();
    final lastThree = numStr.substring(numStr.length - 3);
    final remaining = numStr.substring(0, numStr.length - 3);

    if (remaining.isNotEmpty) {
      var index = remaining.length;
      while (index > 0) {
        final start = (index - 2) < 0 ? 0 : index - 2;
        final part = remaining.substring(start, index);
        if (result.isNotEmpty) {
          result.write(',$part');
        } else {
          result.write(part);
        }
        index -= 2;
      }
      result.write(',$lastThree');
    } else {
      result.write(lastThree);
    }

    return result.toString();
  }

  /// Format date range for display
  String get dateRangeDisplay {
    if (startDate == null && endDate == null) return 'No date set';

    final start = startDate != null ? _formatDisplayDate(startDate!) : 'N/A';
    final end = endDate != null ? _formatDisplayDate(endDate!) : 'N/A';

    return '$start to $end';
  }

  static String _formatDisplayDate(DateTime date) {
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
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'reach': reach,
      'clicks': clicks,
      'orders': orders,
      'revenue': revenue,
      'restaurantCount': restaurantCount,
    };
  }

  CampaignModel copyWith({
    String? id,
    String? name,
    String? type,
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    int? reach,
    int? clicks,
    int? orders,
    double? revenue,
    int? restaurantCount,
    String? description,
    String? discountType,
    double? discountValue,
    double? minOrderValue,
    double? maxDiscount,
    String? offerType,
    List<String>? validDays,
    String? validTimeStart,
    String? validTimeEnd,
    int? usageLimit,
  }) {
    return CampaignModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      reach: reach ?? this.reach,
      clicks: clicks ?? this.clicks,
      orders: orders ?? this.orders,
      revenue: revenue ?? this.revenue,
      restaurantCount: restaurantCount ?? this.restaurantCount,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderValue: minOrderValue ?? this.minOrderValue,
      maxDiscount: maxDiscount ?? this.maxDiscount,
      offerType: offerType ?? this.offerType,
      validDays: validDays ?? this.validDays,
      validTimeStart: validTimeStart ?? this.validTimeStart,
      validTimeEnd: validTimeEnd ?? this.validTimeEnd,
      usageLimit: usageLimit ?? this.usageLimit,
    );
  }

  @override
  String toString() {
    return 'CampaignModel(id: $id, name: $name, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CampaignModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
