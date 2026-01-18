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
