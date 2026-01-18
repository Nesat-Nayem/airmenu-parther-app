import 'package:flutter/material.dart';

/// Model for vendor statistics from API
class VendorStatsModel {
  final int totalOrdersToday;
  final double totalOrdersChange;
  final bool totalOrdersIsPositive;
  final int dineInOrders;
  final double dineInChange;
  final bool dineInIsPositive;
  final int takeawayOrders;
  final double takeawayChange;
  final bool takeawayIsPositive;
  final String avgPrepTime;
  final double avgPrepTimeChange;
  final bool avgPrepTimeIsPositive;
  final double kitchenLoad;
  final double kitchenLoadChange;
  final bool kitchenLoadIsPositive;
  final int inventoryAlerts;
  final String inventoryAlertMessage;

  VendorStatsModel({
    required this.totalOrdersToday,
    required this.totalOrdersChange,
    required this.totalOrdersIsPositive,
    required this.dineInOrders,
    required this.dineInChange,
    required this.dineInIsPositive,
    required this.takeawayOrders,
    required this.takeawayChange,
    required this.takeawayIsPositive,
    required this.avgPrepTime,
    required this.avgPrepTimeChange,
    required this.avgPrepTimeIsPositive,
    required this.kitchenLoad,
    required this.kitchenLoadChange,
    required this.kitchenLoadIsPositive,
    required this.inventoryAlerts,
    required this.inventoryAlertMessage,
  });

  factory VendorStatsModel.fromJson(Map<String, dynamic> json) {
    return VendorStatsModel(
      totalOrdersToday: json['totalOrdersToday'] as int? ?? 0,
      totalOrdersChange: (json['totalOrdersChange'] as num?)?.toDouble() ?? 0.0,
      totalOrdersIsPositive: json['totalOrdersIsPositive'] as bool? ?? true,
      dineInOrders: json['dineInOrders'] as int? ?? 0,
      dineInChange: (json['dineInChange'] as num?)?.toDouble() ?? 0.0,
      dineInIsPositive: json['dineInIsPositive'] as bool? ?? true,
      takeawayOrders: json['takeawayOrders'] as int? ?? 0,
      takeawayChange: (json['takeawayChange'] as num?)?.toDouble() ?? 0.0,
      takeawayIsPositive: json['takeawayIsPositive'] as bool? ?? true,
      avgPrepTime: json['avgPrepTime'] as String? ?? '0min',
      avgPrepTimeChange: (json['avgPrepTimeChange'] as num?)?.toDouble() ?? 0.0,
      avgPrepTimeIsPositive: json['avgPrepTimeIsPositive'] as bool? ?? false,
      kitchenLoad: (json['kitchenLoad'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadChange: (json['kitchenLoadChange'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadIsPositive: json['kitchenLoadIsPositive'] as bool? ?? false,
      inventoryAlerts: json['inventoryAlerts'] as int? ?? 0,
      inventoryAlertMessage: json['inventoryAlertMessage'] as String? ?? '',
    );
  }

  /// Convert to list of stat cards for UI
  List<VendorStatCardData> toStatCards() {
    return [
      VendorStatCardData(
        label: 'Total Orders Today',
        value: totalOrdersToday.toString(),
        change: '${totalOrdersChange.toStringAsFixed(0)}%',
        isPositive: totalOrdersIsPositive,
        icon: Icons.shopping_bag,
        color: const Color(0xFFF8E8E8),
        iconColor: const Color(0xFFDC2626),
        subtitle: 'vs yesterday',
      ),
      VendorStatCardData(
        label: 'Dine-in Orders',
        value: dineInOrders.toString(),
        change: '${dineInChange.toStringAsFixed(0)}%',
        isPositive: dineInIsPositive,
        icon: Icons.restaurant,
        color: const Color(0xFFF8E8E8),
        iconColor: const Color(0xFFDC2626),
        subtitle: 'vs yesterday',
      ),
      VendorStatCardData(
        label: 'Takeaway Orders',
        value: takeawayOrders.toString(),
        change: '${takeawayChange.toStringAsFixed(0)}%',
        isPositive: takeawayIsPositive,
        icon: Icons.takeout_dining,
        color: const Color(0xFFFEF3E8),
        iconColor: const Color(0xFFF59E0B),
        subtitle: 'vs yesterday',
      ),
      VendorStatCardData(
        label: 'Avg Prep Time',
        value: avgPrepTime,
        change: '${avgPrepTimeChange.toStringAsFixed(0)}%',
        isPositive: avgPrepTimeIsPositive,
        icon: Icons.access_time,
        color: const Color(0xFFF8E8E8),
        iconColor: const Color(0xFFDC2626),
        subtitle: 'vs yesterday',
      ),
      VendorStatCardData(
        label: 'Kitchen Load',
        value: '${kitchenLoad.toStringAsFixed(0)}%',
        change: kitchenLoadChange > 0 ? 'High Load' : 'Normal',
        isPositive: !kitchenLoadIsPositive,
        icon: Icons.local_fire_department,
        color: const Color(0xFFF8E8E8),
        iconColor: const Color(0xFFDC2626),
        subtitle: kitchenLoad > 70 ? 'High Load' : 'Normal',
      ),
      VendorStatCardData(
        label: 'Inventory Alerts',
        value: inventoryAlerts.toString(),
        change: inventoryAlertMessage,
        isPositive: inventoryAlerts == 0,
        icon: Icons.warning_amber,
        color: const Color(0xFFFFF5F5),
        iconColor: const Color(0xFFDC2626),
        subtitle: 'Items need attention',
      ),
    ];
  }
}

/// Helper class for vendor stat card display
class VendorStatCardData {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final Color iconColor;
  final String subtitle;

  VendorStatCardData({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.subtitle,
  });
}

/// Model for orders over time chart (hourly distribution)
class OrdersOverTimeModel {
  final List<String> labels;
  final List<int> orderCounts;
  final String period;

  OrdersOverTimeModel({
    required this.labels,
    required this.orderCounts,
    required this.period,
  });

  factory OrdersOverTimeModel.fromJson(Map<String, dynamic> json) {
    return OrdersOverTimeModel(
      labels:
          (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      orderCounts:
          (json['orderCounts'] as List?)?.map((e) => e as int).toList() ?? [],
      period: json['period'] as String? ?? 'today',
    );
  }
}

/// Model for category performance (horizontal bar chart)
class CategoryPerformanceModel {
  final String categoryName;
  final int orderCount;
  final Color barColor;

  CategoryPerformanceModel({
    required this.categoryName,
    required this.orderCount,
    this.barColor = const Color(0xFFDC2626),
  });

  factory CategoryPerformanceModel.fromJson(Map<String, dynamic> json) {
    return CategoryPerformanceModel(
      categoryName: json['categoryName'] as String? ?? '',
      orderCount: json['orderCount'] as int? ?? 0,
      barColor: const Color(0xFFDC2626),
    );
  }
}

/// Model for order type breakdown (donut chart)
class OrderTypeBreakdownModel {
  final int dineInCount;
  final int takeawayCount;
  final int deliveryCount;

  OrderTypeBreakdownModel({
    required this.dineInCount,
    required this.takeawayCount,
    required this.deliveryCount,
  });

  factory OrderTypeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return OrderTypeBreakdownModel(
      dineInCount: json['dineInCount'] as int? ?? 0,
      takeawayCount: json['takeawayCount'] as int? ?? 0,
      deliveryCount: json['deliveryCount'] as int? ?? 0,
    );
  }

  int get total => dineInCount + takeawayCount + deliveryCount;

  double get dineInPercentage => total > 0 ? (dineInCount / total) * 100 : 0;
  double get takeawayPercentage =>
      total > 0 ? (takeawayCount / total) * 100 : 0;
  double get deliveryPercentage =>
      total > 0 ? (deliveryCount / total) * 100 : 0;
}

/// Model for bestselling items
class BestsellingItemModel {
  final int rank;
  final String itemName;
  final int unitsSold;
  final double revenue;
  final double revenueChange;
  final bool revenueChangeIsPositive;

  BestsellingItemModel({
    required this.rank,
    required this.itemName,
    required this.unitsSold,
    required this.revenue,
    required this.revenueChange,
    required this.revenueChangeIsPositive,
  });

  factory BestsellingItemModel.fromJson(Map<String, dynamic> json) {
    return BestsellingItemModel(
      rank: json['rank'] as int? ?? 0,
      itemName: json['itemName'] as String? ?? '',
      unitsSold: json['unitsSold'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0.0,
      revenueChangeIsPositive: json['revenueChangeIsPositive'] as bool? ?? true,
    );
  }
}

/// Model for recent orders
class RecentOrderModel {
  final String orderId;
  final String orderType;
  final String tableSource;
  final int itemCount;
  final String status;
  final String timeAgo;

  RecentOrderModel({
    required this.orderId,
    required this.orderType,
    required this.tableSource,
    required this.itemCount,
    required this.status,
    required this.timeAgo,
  });

  factory RecentOrderModel.fromJson(Map<String, dynamic> json) {
    return RecentOrderModel(
      orderId: json['orderId'] as String? ?? '',
      orderType: json['orderType'] as String? ?? '',
      tableSource: json['tableSource'] as String? ?? '',
      itemCount: json['itemCount'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
    );
  }

  Color get orderTypeColor {
    switch (orderType.toLowerCase()) {
      case 'dine-in':
        return const Color(0xFFDC2626);
      case 'takeaway':
        return const Color(0xFFF59E0B);
      case 'delivery':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'preparing':
        return const Color(0xFFDC2626);
      case 'ready':
        return const Color(0xFF10B981);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'served':
        return const Color(0xFF6B7280);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Color get statusBackgroundColor {
    switch (status.toLowerCase()) {
      case 'preparing':
        return const Color(0xFFFEE2E2);
      case 'ready':
        return const Color(0xFFD1FAE5);
      case 'pending':
        return const Color(0xFFFEF3C7);
      case 'served':
        return const Color(0xFFF3F4F6);
      default:
        return const Color(0xFFF3F4F6);
    }
  }
}

/// Aggregated vendor dashboard data model
class VendorDashboardDataModel {
  final VendorStatsModel stats;
  final OrdersOverTimeModel ordersOverTime;
  final List<CategoryPerformanceModel> categoryPerformance;
  final OrderTypeBreakdownModel orderTypeBreakdown;
  final List<BestsellingItemModel> bestsellingItems;
  final List<RecentOrderModel> recentOrders;

  VendorDashboardDataModel({
    required this.stats,
    required this.ordersOverTime,
    required this.categoryPerformance,
    required this.orderTypeBreakdown,
    required this.bestsellingItems,
    required this.recentOrders,
  });

  VendorDashboardDataModel copyWith({
    VendorStatsModel? stats,
    OrdersOverTimeModel? ordersOverTime,
    List<CategoryPerformanceModel>? categoryPerformance,
    OrderTypeBreakdownModel? orderTypeBreakdown,
    List<BestsellingItemModel>? bestsellingItems,
    List<RecentOrderModel>? recentOrders,
  }) {
    return VendorDashboardDataModel(
      stats: stats ?? this.stats,
      ordersOverTime: ordersOverTime ?? this.ordersOverTime,
      categoryPerformance: categoryPerformance ?? this.categoryPerformance,
      orderTypeBreakdown: orderTypeBreakdown ?? this.orderTypeBreakdown,
      bestsellingItems: bestsellingItems ?? this.bestsellingItems,
      recentOrders: recentOrders ?? this.recentOrders,
    );
  }

  factory VendorDashboardDataModel.empty() {
    return VendorDashboardDataModel(
      stats: VendorStatsModel.fromJson({}),
      ordersOverTime: OrdersOverTimeModel.fromJson({}),
      categoryPerformance: [],
      orderTypeBreakdown: OrderTypeBreakdownModel.fromJson({}),
      bestsellingItems: [],
      recentOrders: [],
    );
  }
}

/// Helper for Top Menu Items
class TopMenuItem {
  final String id;
  final String title;
  final String image;
  final int totalOrders;
  final double totalRevenue;

  TopMenuItem({
    required this.id,
    required this.title,
    required this.image,
    required this.totalOrders,
    required this.totalRevenue,
  });

  factory TopMenuItem.fromJson(Map<String, dynamic> json) {
    return TopMenuItem(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      image: json['image'] as String? ?? '',
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// API Response for Dashboard Stats
class DashboardStatsResponse {
  final int totalOrders;
  final double totalOrdersChange;
  final bool totalOrdersIsPositive;
  final double totalRevenue;
  final double revenueChange;
  final bool revenueIsPositive;
  final int dineInOrders;
  final double dineInChange;
  final bool dineInIsPositive;
  final int takeawayOrders;
  final double takeawayChange;
  final bool takeawayIsPositive;
  final String avgPrepTime;
  final double avgPrepTimeChange;
  final bool avgPrepTimeIsPositive;
  final double kitchenLoad;
  final double kitchenLoadChange;
  final bool kitchenLoadIsPositive;
  final int inventoryAlerts;
  final String inventoryAlertMessage;
  final List<TopMenuItem> topMenuItems;

  DashboardStatsResponse({
    required this.totalOrders,
    required this.totalOrdersChange,
    required this.totalOrdersIsPositive,
    required this.totalRevenue,
    required this.revenueChange,
    required this.revenueIsPositive,
    required this.dineInOrders,
    required this.dineInChange,
    required this.dineInIsPositive,
    required this.takeawayOrders,
    required this.takeawayChange,
    required this.takeawayIsPositive,
    required this.avgPrepTime,
    required this.avgPrepTimeChange,
    required this.avgPrepTimeIsPositive,
    required this.kitchenLoad,
    required this.kitchenLoadChange,
    required this.kitchenLoadIsPositive,
    required this.inventoryAlerts,
    required this.inventoryAlertMessage,
    required this.topMenuItems,
  });

  factory DashboardStatsResponse.fromJson(Map<String, dynamic> json) {
    return DashboardStatsResponse(
      totalOrders: json['totalOrders'] as int? ?? 0,
      totalOrdersChange: (json['totalOrdersChange'] as num?)?.toDouble() ?? 0.0,
      totalOrdersIsPositive: json['totalOrdersIsPositive'] as bool? ?? true,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0.0,
      revenueIsPositive: json['revenueIsPositive'] as bool? ?? true,
      dineInOrders: json['dineInOrders'] as int? ?? 0,
      dineInChange: (json['dineInChange'] as num?)?.toDouble() ?? 0.0,
      dineInIsPositive: json['dineInIsPositive'] as bool? ?? true,
      takeawayOrders: json['takeawayOrders'] as int? ?? 0,
      takeawayChange: (json['takeawayChange'] as num?)?.toDouble() ?? 0.0,
      takeawayIsPositive: json['takeawayIsPositive'] as bool? ?? true,
      avgPrepTime: json['avgPrepTime'] as String? ?? '0min',
      avgPrepTimeChange: (json['avgPrepTimeChange'] as num?)?.toDouble() ?? 0.0,
      avgPrepTimeIsPositive: json['avgPrepTimeIsPositive'] as bool? ?? true,
      kitchenLoad: (json['kitchenLoad'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadChange: (json['kitchenLoadChange'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadIsPositive: json['kitchenLoadIsPositive'] as bool? ?? false,
      inventoryAlerts: json['inventoryAlerts'] as int? ?? 0,
      inventoryAlertMessage: json['inventoryAlertMessage'] as String? ?? '',
      topMenuItems:
          (json['topMenuItems'] as List?)
              ?.map((e) => TopMenuItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// Helper for Order Stats items
class OrderStatItem {
  final int value;
  final String? comparison;
  final String? label;

  OrderStatItem({required this.value, this.comparison, this.label});

  factory OrderStatItem.fromJson(Map<String, dynamic> json) {
    return OrderStatItem(
      value: json['value'] as int? ?? 0,
      comparison: json['comparison'] as String?,
      label: json['label'] as String?,
    );
  }
}

/// API Response for Order Stats
class OrderStatsResponse {
  final OrderStatItem pending;
  final OrderStatItem inKitchen;
  final OrderStatItem ready;
  final OrderStatItem delayed;

  OrderStatsResponse({
    required this.pending,
    required this.inKitchen,
    required this.ready,
    required this.delayed,
  });

  factory OrderStatsResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatsResponse(
      pending: OrderStatItem.fromJson(
        json['pending'] as Map<String, dynamic>? ?? {},
      ),
      inKitchen: OrderStatItem.fromJson(
        json['inKitchen'] as Map<String, dynamic>? ?? {},
      ),
      ready: OrderStatItem.fromJson(
        json['ready'] as Map<String, dynamic>? ?? {},
      ),
      delayed: OrderStatItem.fromJson(
        json['delayed'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}

/// Model for Branch/Outlet
class BranchModel {
  final String id;
  final String name;

  BranchModel({required this.id, required this.name});

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }
}
