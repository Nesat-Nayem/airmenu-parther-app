/// Model for individual stat item from API (for tiles)
/// Example: {"key": "pending", "label": "Pending", "value": 0, "comparison": "0%", "comparisonLabel": "vs yesterday", "trend": "neutral"}
/// Note: value can be int (e.g., 0) or string (e.g., "18 min" for avgPrepTime)
class OrderStatItemModel {
  final String? key;
  final String? label;
  final dynamic value; // Can be int or String (e.g., "18 min")
  final String? comparison;
  final String? comparisonLabel;
  final String? trend;

  const OrderStatItemModel({
    this.key,
    this.label,
    this.value,
    this.comparison,
    this.comparisonLabel,
    this.trend,
  });

  factory OrderStatItemModel.fromJson(Map<String, dynamic> json) {
    return OrderStatItemModel(
      key: json['key'] as String?,
      label: json['label'] as String?,
      value: json['value'], // Keep as dynamic - can be int or String
      comparison: json['comparison'] as String?,
      comparisonLabel: json['comparisonLabel'] as String?,
      trend: json['trend'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'value': value,
    'comparison': comparison,
    'comparisonLabel': comparisonLabel,
    'trend': trend,
  };

  /// Get value as int (returns 0 if value is string)
  int get intValue => value is int ? value : 0;

  /// Get value as display string
  String get displayValue => value?.toString() ?? '0';

  /// Returns true if trend is positive (up)
  bool get isPositiveTrend => trend == 'up';

  /// Returns true if trend is negative (down)
  bool get isNegativeTrend => trend == 'down';

  /// Returns true if trend is neutral
  bool get isNeutralTrend => trend == 'neutral' || trend == null;
}

/// Model for filter item from API (for filter tabs)
/// Example: {"key": "all", "label": "All Orders", "count": 0, "isDefault": true}
class OrderFilterModel {
  final String? key;
  final String? label;
  final int? count;
  final bool? isDefault;

  const OrderFilterModel({this.key, this.label, this.count, this.isDefault});

  factory OrderFilterModel.fromJson(Map<String, dynamic> json) {
    return OrderFilterModel(
      key: json['key'] as String?,
      label: json['label'] as String?,
      count: json['count'] as int? ?? 0,
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'key': key,
    'label': label,
    'count': count,
    'isDefault': isDefault,
  };
}

/// Model for order statistics response from /orders/order-stats API
/// Contains stats for tiles and filters for filter tabs
class OrderStatsModel {
  /// Stats for top tiles (Pending, In Kitchen, Ready, Delayed)
  final List<OrderStatItemModel>? stats;

  /// Filters for filter tabs (All Orders, Pending, Processing, etc.)
  final List<OrderFilterModel>? filters;

  const OrderStatsModel({this.stats, this.filters});

  factory OrderStatsModel.fromJson(Map<String, dynamic> json) {
    return OrderStatsModel(
      stats: (json['stats'] as List<dynamic>?)
          ?.map((e) => OrderStatItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      filters: (json['filters'] as List<dynamic>?)
          ?.map((e) => OrderFilterModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'stats': stats?.map((e) => e.toJson()).toList(),
    'filters': filters?.map((e) => e.toJson()).toList(),
  };

  /// Get stat item by key
  OrderStatItemModel? getStatByKey(String key) {
    return stats?.firstWhere(
      (stat) => stat.key == key,
      orElse: () => const OrderStatItemModel(),
    );
  }

  /// Get filter item by key
  OrderFilterModel? getFilterByKey(String key) {
    return filters?.firstWhere(
      (filter) => filter.key == key,
      orElse: () => const OrderFilterModel(),
    );
  }

  /// Get default filter
  OrderFilterModel? get defaultFilter {
    return filters?.firstWhere(
      (filter) => filter.isDefault == true,
      orElse: () => filters?.isNotEmpty == true
          ? filters!.first
          : const OrderFilterModel(),
    );
  }

  /// Get filter counts as a map (for backwards compatibility)
  Map<String, int> get filterCounts {
    final counts = <String, int>{};
    if (filters != null) {
      for (final filter in filters!) {
        if (filter.key != null) {
          counts[filter.key!] = filter.count ?? 0;
        }
      }
    }
    return counts;
  }

  /// Empty stats for loading/error states
  static const OrderStatsModel empty = OrderStatsModel();
}
