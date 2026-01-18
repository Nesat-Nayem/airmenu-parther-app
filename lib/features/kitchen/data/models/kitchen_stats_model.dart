/// Kitchen statistics model with comparison from /kitchen-load/stats-comparison/:hotelId
class KitchenStatsModel {
  final KitchenStatItem? ordersInQueue;
  final KitchenStatItem? itemsInProgress;
  final KitchenStatItem? avgPrepTime;
  final KitchenStatItem? delayedOrders;
  final KitchenStatItem? completedToday;

  const KitchenStatsModel({
    this.ordersInQueue,
    this.itemsInProgress,
    this.avgPrepTime,
    this.delayedOrders,
    this.completedToday,
  });

  factory KitchenStatsModel.fromJson(Map<String, dynamic> json) {
    return KitchenStatsModel(
      ordersInQueue: json['ordersInQueue'] != null
          ? KitchenStatItem.fromJson(json['ordersInQueue'])
          : null,
      itemsInProgress: json['itemsInProgress'] != null
          ? KitchenStatItem.fromJson(json['itemsInProgress'])
          : null,
      avgPrepTime: json['avgPrepTime'] != null
          ? KitchenStatItem.fromJson(json['avgPrepTime'])
          : null,
      delayedOrders: json['delayedOrders'] != null
          ? KitchenStatItem.fromJson(json['delayedOrders'])
          : null,
      completedToday: json['completedToday'] != null
          ? KitchenStatItem.fromJson(json['completedToday'])
          : null,
    );
  }

  static const KitchenStatsModel empty = KitchenStatsModel();
}

/// Individual stat item with value, comparison, and label
class KitchenStatItem {
  final dynamic value;
  final String? comparison;
  final String? label;

  const KitchenStatItem({required this.value, this.comparison, this.label});

  factory KitchenStatItem.fromJson(Map<String, dynamic> json) {
    return KitchenStatItem(
      value: json['value'],
      comparison: json['comparison'] as String?,
      label: json['label'] as String?,
    );
  }

  /// Get value as int
  int get intValue =>
      value is int ? value : int.tryParse(value.toString()) ?? 0;

  /// Get value as String
  String get stringValue => value?.toString() ?? '0';

  /// Returns formatted comparison text (e.g., "5% vs yesterday")
  String? get formattedComparison {
    if (comparison == null || label == null) return null;
    return '$comparison $label';
  }

  /// Returns true if comparison is positive
  bool get isPositiveComparison {
    if (comparison == null) return false;
    final num = int.tryParse(
      comparison!.replaceAll('%', '').replaceAll('-', ''),
    );
    final isNegative = comparison!.contains('-');
    return num != null && !isNegative && num > 0;
  }
}
