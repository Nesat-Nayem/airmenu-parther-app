/// Model for individual stat item from API

/// Model for individual stat item from API
class StatItem {
  final int value;
  final String? comparison;
  final String? label;

  const StatItem({required this.value, this.comparison, this.label});

  factory StatItem.fromJson(Map<String, dynamic> json) {
    return StatItem(
      value: json['value'] as int? ?? 0,
      comparison: json['comparison'] as String?,
      label: json['label'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'value': value,
    'comparison': comparison,
    'label': label,
  };

  /// Returns formatted comparison text (e.g., "50% vs yesterday")
  String? get formattedComparison {
    if (comparison == null || label == null) return null;
    return '$comparison $label';
  }

  /// Returns true if comparison is positive (increase)
  bool get isPositiveComparison {
    if (comparison == null) return false;
    final numericValue = int.tryParse(comparison!.replaceAll('%', ''));
    return numericValue != null && numericValue > 0;
  }
}

/// Model for order statistics from /orders/order-stats API
class OrderStatsModel {
  final StatItem? totalOrders;
  final StatItem? pending;
  final StatItem? inKitchen;
  final StatItem? ready;
  final StatItem? served;
  final StatItem? cancelled;
  final StatItem? delayed;

  // Admin-specific stats
  final StatItem? activeOrders;
  final StatItem? avgPrepTime;
  final StatItem? completedToday;

  const OrderStatsModel({
    this.totalOrders,
    this.pending,
    this.inKitchen,
    this.ready,
    this.served,
    this.cancelled,
    this.delayed,
    this.activeOrders,
    this.avgPrepTime,
    this.completedToday,
  });

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsModel(
      totalOrders: json['totalOrders'] != null
          ? StatItem.fromJson(json['totalOrders'])
          : null,
      pending: json['pending'] != null
          ? StatItem.fromJson(json['pending'])
          : null,
      inKitchen: json['inKitchen'] != null
          ? StatItem.fromJson(json['inKitchen'])
          : null,
      ready: json['ready'] != null ? StatItem.fromJson(json['ready']) : null,
      served: json['served'] != null ? StatItem.fromJson(json['served']) : null,
      cancelled: json['cancelled'] != null
          ? StatItem.fromJson(json['cancelled'])
          : null,
      delayed: json['delayed'] != null
          ? StatItem.fromJson(json['delayed'])
          : null,
      // Admin stats
      activeOrders: json['activeOrders'] != null
          ? StatItem.fromJson(json['activeOrders'])
          : null,
      avgPrepTime: json['avgPrepTime'] != null
          ? StatItem.fromJson(json['avgPrepTime'])
          : null,
      completedToday: json['completedToday'] != null
          ? StatItem.fromJson(json['completedToday'])
          : null,
    );
  }

  /// Get filter counts as a map for filter chips
  Map<String, int> get filterCounts => {
    'All Orders': totalOrders?.value ?? 0,
    'Pending': pending?.value ?? 0,
    'In Kitchen': inKitchen?.value ?? 0,
    'Ready': ready?.value ?? 0,
    'Served': served?.value ?? 0,
    'Cancelled': cancelled?.value ?? 0,
  };

  /// Empty stats for loading/error states
  static const OrderStatsModel empty = OrderStatsModel();
}
