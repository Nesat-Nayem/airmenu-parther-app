import 'package:flutter/material.dart';

/// Model for platform statistics from API
class DashboardStatsModel {
  final int activeRestaurants;
  final double activeRestaurantsChange;
  final bool activeRestaurantsIsPositive;
  final int pendingOnboarding;
  final double pendingOnboardingChange;
  final bool pendingOnboardingIsPositive;
  final int ordersToday;
  final double ordersTodayChange;
  final bool ordersTodayIsPositive;
  final double gmvToday;
  final double gmvChange;
  final bool gmvIsPositive;
  final double avgKitchenLoad;
  final double kitchenLoadChange;
  final bool kitchenLoadIsPositive;
  final double deliverySuccessRate;
  final double deliverySuccessChange;
  final bool deliverySuccessIsPositive;
  final int activeRiders;
  final double activeRidersChange;
  final bool activeRidersIsPositive;
  final int totalUsers;

  DashboardStatsModel({
    required this.activeRestaurants,
    required this.activeRestaurantsChange,
    required this.activeRestaurantsIsPositive,
    required this.pendingOnboarding,
    required this.pendingOnboardingChange,
    required this.pendingOnboardingIsPositive,
    required this.ordersToday,
    required this.ordersTodayChange,
    required this.ordersTodayIsPositive,
    required this.gmvToday,
    required this.gmvChange,
    required this.gmvIsPositive,
    required this.avgKitchenLoad,
    required this.kitchenLoadChange,
    required this.kitchenLoadIsPositive,
    required this.deliverySuccessRate,
    required this.deliverySuccessChange,
    required this.deliverySuccessIsPositive,
    required this.activeRiders,
    required this.activeRidersChange,
    required this.activeRidersIsPositive,
    required this.totalUsers,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      activeRestaurants: json['activeRestaurants'] as int? ?? 0,
      activeRestaurantsChange:
          (json['activeRestaurantsChange'] as num?)?.toDouble() ?? 0.0,
      activeRestaurantsIsPositive:
          json['activeRestaurantsIsPositive'] as bool? ?? true,
      pendingOnboarding: json['pendingOnboarding'] as int? ?? 0,
      pendingOnboardingChange:
          (json['pendingOnboardingChange'] as num?)?.toDouble() ?? 0.0,
      pendingOnboardingIsPositive:
          json['pendingOnboardingIsPositive'] as bool? ?? true,
      ordersToday: json['ordersToday'] as int? ?? 0,
      ordersTodayChange: (json['ordersTodayChange'] as num?)?.toDouble() ?? 0.0,
      ordersTodayIsPositive: json['ordersTodayIsPositive'] as bool? ?? true,
      gmvToday: (json['gmvToday'] as num?)?.toDouble() ?? 0.0,
      gmvChange: (json['gmvChange'] as num?)?.toDouble() ?? 0.0,
      gmvIsPositive: json['gmvIsPositive'] as bool? ?? true,
      avgKitchenLoad: (json['avgKitchenLoad'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadChange: (json['kitchenLoadChange'] as num?)?.toDouble() ?? 0.0,
      kitchenLoadIsPositive: json['kitchenLoadIsPositive'] as bool? ?? true,
      deliverySuccessRate:
          (json['deliverySuccessRate'] as num?)?.toDouble() ?? 0.0,
      deliverySuccessChange:
          (json['deliverySuccessChange'] as num?)?.toDouble() ?? 0.0,
      deliverySuccessIsPositive:
          json['deliverySuccessIsPositive'] as bool? ?? true,
      activeRiders: json['activeRiders'] as int? ?? 0,
      activeRidersChange:
          (json['activeRidersChange'] as num?)?.toDouble() ?? 0.0,
      activeRidersIsPositive: json['activeRidersIsPositive'] as bool? ?? true,
      totalUsers: json['totalUsers'] as int? ?? 0,
    );
  }

  // Convert to list of stat cards for UI
  List<StatCardData> toStatCards() {
    return [
      StatCardData(
        label: 'Active Restaurants',
        value: activeRestaurants.toString(),
        change: '${activeRestaurantsChange.toStringAsFixed(0)}%',
        isPositive: activeRestaurantsIsPositive,
        icon: Icons.restaurant,
        color: const Color(0xFFDC2626),
      ),
      StatCardData(
        label: 'Pending Onboarding',
        value: pendingOnboarding.toString(),
        change: '${pendingOnboardingChange.toStringAsFixed(0)}%',
        isPositive: pendingOnboardingIsPositive,
        icon: Icons.pending_actions,
        color: const Color(0xFFF59E0B),
      ),
      StatCardData(
        label: 'Orders Today',
        value: ordersToday.toString(),
        change: '${ordersTodayChange.toStringAsFixed(0)}%',
        isPositive: ordersTodayIsPositive,
        icon: Icons.shopping_bag,
        color: const Color(0xFF10B981),
      ),
      StatCardData(
        label: 'GMV Today',
        value: '₹${(gmvToday / 100000).toStringAsFixed(2)}L',
        change: '${gmvChange.toStringAsFixed(0)}%',
        isPositive: gmvIsPositive,
        icon: Icons.currency_rupee,
        color: const Color(0xFF8B5CF6),
      ),
      StatCardData(
        label: 'Avg Kitchen Load',
        value: '${avgKitchenLoad.toStringAsFixed(0)}%',
        change: '${kitchenLoadChange.toStringAsFixed(0)}%',
        isPositive: kitchenLoadIsPositive,
        icon: Icons.kitchen,
        color: const Color(0xFFEF4444),
      ),
      StatCardData(
        label: 'Delivery Success',
        value: '${deliverySuccessRate.toStringAsFixed(1)}%',
        change: '${deliverySuccessChange.toStringAsFixed(1)}%',
        isPositive: deliverySuccessIsPositive,
        icon: Icons.check_circle,
        color: const Color(0xFF059669),
      ),
      StatCardData(
        label: 'Active Riders',
        value: activeRiders.toString(),
        change: '${activeRidersChange.toStringAsFixed(0)}%',
        isPositive: activeRidersIsPositive,
        icon: Icons.delivery_dining,
        color: const Color(0xFF3B82F6),
      ),
      StatCardData(
        label: 'Total Users',
        value: totalUsers.toString(),
        change: '+0%',
        isPositive: true,
        icon: Icons.people,
        color: const Color(0xFF6366F1),
      ),
    ];
  }
}

/// Helper class for stat card display
class StatCardData {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;

  StatCardData({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
  });
}

/// Model for high-risk alerts
class HighRiskAlertModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String severity; // 'high', 'medium', 'low'
  final String type;
  final String message;
  final String timestamp;
  final String status; // 'active', 'resolved'
  final Map<String, dynamic>? metadata;

  HighRiskAlertModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.severity,
    required this.type,
    required this.message,
    required this.timestamp,
    required this.status,
    this.metadata,
  });

  factory HighRiskAlertModel.fromJson(Map<String, dynamic> json) {
    return HighRiskAlertModel(
      id: json['id'] as String? ?? '',
      restaurantId: json['restaurantId'] as String? ?? '',
      restaurantName: json['restaurantName'] as String? ?? '',
      severity: json['severity'] as String? ?? 'medium',
      type: json['type'] as String? ?? '',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
}

/// Model for live activity feed
class LiveActivityModel {
  final String id;
  final String restaurantId;
  final String restaurantName;
  final String type;
  final String description;
  final String timestamp;
  final String timeAgo;
  final Map<String, dynamic>? metadata;

  LiveActivityModel({
    required this.id,
    required this.restaurantId,
    required this.restaurantName,
    required this.type,
    required this.description,
    required this.timestamp,
    required this.timeAgo,
    this.metadata,
  });

  factory LiveActivityModel.fromJson(Map<String, dynamic> json) {
    return LiveActivityModel(
      id: json['id'] as String? ?? '',
      restaurantId: json['restaurantId'] as String? ?? '',
      restaurantName: json['restaurantName'] as String? ?? '',
      type: json['type'] as String? ?? 'order',
      description: json['description'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? '',
      timeAgo: json['timeAgo'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  IconData get icon {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return Icons.restaurant;
      case 'menu_category':
        return Icons.category;
      case 'order':
        return Icons.receipt_long;
      default:
        return Icons.info;
    }
  }

  Color get iconColor {
    switch (type.toLowerCase()) {
      case 'restaurant':
        return const Color(0xFF10B981);
      case 'menu_category':
        return const Color(0xFF3B82F6);
      case 'order':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF6B7280);
    }
  }
}

/// Model for top restaurants
class TopRestaurantModel {
  final String id;
  final String name;
  final String category;
  final int orders;
  final double revenue;
  final String prepTime;
  final int queue;
  final double healthPercentage;
  final String status;
  final double slaCompliance;

  TopRestaurantModel({
    required this.id,
    required this.name,
    required this.category,
    required this.orders,
    required this.revenue,
    required this.prepTime,
    required this.queue,
    required this.healthPercentage,
    required this.status,
    required this.slaCompliance,
  });

  factory TopRestaurantModel.fromJson(Map<String, dynamic> json) {
    return TopRestaurantModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
      prepTime: json['prepTime'] as String? ?? '0m',
      queue: json['queue'] as int? ?? 0,
      healthPercentage: (json['healthPercentage'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      slaCompliance: (json['slaCompliance'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Model for orders by type chart
class OrdersByTypeChartModel {
  final List<String> labels;
  final List<int> dineIn;
  final List<int> takeaway;
  final List<int> qsr;
  final List<int> roomService;
  final List<int> theatre;

  OrdersByTypeChartModel({
    required this.labels,
    required this.dineIn,
    required this.takeaway,
    required this.qsr,
    required this.roomService,
    required this.theatre,
  });

  factory OrdersByTypeChartModel.fromJson(Map<String, dynamic> json) {
    final datasets = json['datasets'] as Map<String, dynamic>? ?? {};
    return OrdersByTypeChartModel(
      labels:
          (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      dineIn:
          (datasets['dineIn'] as List?)?.map((e) => e as int).toList() ?? [],
      takeaway:
          (datasets['takeaway'] as List?)?.map((e) => e as int).toList() ?? [],
      qsr: (datasets['qsr'] as List?)?.map((e) => e as int).toList() ?? [],
      roomService:
          (datasets['roomService'] as List?)?.map((e) => e as int).toList() ??
          [],
      theatre:
          (datasets['theatre'] as List?)?.map((e) => e as int).toList() ?? [],
    );
  }
}

/// Model for kitchen load chart
class KitchenLoadChartModel {
  final List<String> labels;
  final List<int> loadPercentages;
  final int normalThreshold;
  final int highThreshold;

  KitchenLoadChartModel({
    required this.labels,
    required this.loadPercentages,
    required this.normalThreshold,
    required this.highThreshold,
  });

  factory KitchenLoadChartModel.fromJson(Map<String, dynamic> json) {
    final thresholds = json['thresholds'] as Map<String, dynamic>? ?? {};
    return KitchenLoadChartModel(
      labels:
          (json['labels'] as List?)?.map((e) => e.toString()).toList() ?? [],
      loadPercentages:
          (json['loadPercentages'] as List?)?.map((e) => e as int).toList() ??
          [],
      normalThreshold: thresholds['normal'] as int? ?? 70,
      highThreshold: thresholds['high'] as int? ?? 85,
    );
  }
}

/// Model for restaurant performance
class RestaurantPerformanceModel {
  final String restaurantName;
  final int orders;
  final double slaPercentage;
  final String avgPrepTime;
  final int currentQueue;

  RestaurantPerformanceModel({
    required this.restaurantName,
    required this.orders,
    required this.slaPercentage,
    required this.avgPrepTime,
    required this.currentQueue,
  });

  factory RestaurantPerformanceModel.fromJson(Map<String, dynamic> json) {
    return RestaurantPerformanceModel(
      restaurantName: json['restaurantName'] as String? ?? '',
      orders: json['orders'] as int? ?? 0,
      slaPercentage: (json['slaPercentage'] as num?)?.toDouble() ?? 0.0,
      avgPrepTime: json['avgPrepTime'] as String? ?? '0m',
      currentQueue: json['currentQueue'] as int? ?? 0,
    );
  }
}

/// Model for rider SLA
class RiderSLAModel {
  final String partnerName;
  final double slaPercentage;
  final String avgDeliveryTime;

  RiderSLAModel({
    required this.partnerName,
    required this.slaPercentage,
    required this.avgDeliveryTime,
  });

  factory RiderSLAModel.fromJson(Map<String, dynamic> json) {
    return RiderSLAModel(
      partnerName: json['partnerName'] as String? ?? '',
      slaPercentage: (json['slaPercentage'] as num?)?.toDouble() ?? 0.0,
      avgDeliveryTime: json['avgDeliveryTime'] as String? ?? '0m',
    );
  }
}

/// Aggregated dashboard data model
class DashboardDataModel {
  final DashboardStatsModel stats;
  final List<HighRiskAlertModel> alerts;
  final List<LiveActivityModel> liveActivities;
  final List<TopRestaurantModel> topRestaurants;
  final OrdersByTypeChartModel? ordersByType;
  final KitchenLoadChartModel? kitchenLoad;
  final List<RestaurantPerformanceModel> restaurantPerformance;
  final List<RiderSLAModel> riderSLA;

  DashboardDataModel({
    required this.stats,
    required this.alerts,
    required this.liveActivities,
    required this.topRestaurants,
    this.ordersByType,
    this.kitchenLoad,
    required this.restaurantPerformance,
    required this.riderSLA,
  });

  DashboardDataModel copyWith({
    DashboardStatsModel? stats,
    List<HighRiskAlertModel>? alerts,
    List<LiveActivityModel>? liveActivities,
    List<TopRestaurantModel>? topRestaurants,
    OrdersByTypeChartModel? ordersByType,
    KitchenLoadChartModel? kitchenLoad,
    List<RestaurantPerformanceModel>? restaurantPerformance,
    List<RiderSLAModel>? riderSLA,
  }) {
    return DashboardDataModel(
      stats: stats ?? this.stats,
      alerts: alerts ?? this.alerts,
      liveActivities: liveActivities ?? this.liveActivities,
      topRestaurants: topRestaurants ?? this.topRestaurants,
      ordersByType: ordersByType ?? this.ordersByType,
      kitchenLoad: kitchenLoad ?? this.kitchenLoad,
      restaurantPerformance:
          restaurantPerformance ?? this.restaurantPerformance,
      riderSLA: riderSLA ?? this.riderSLA,
    );
  }

  factory DashboardDataModel.empty() {
    return DashboardDataModel(
      stats: DashboardStatsModel.fromJson({}),
      alerts: [],
      liveActivities: [],
      topRestaurants: [],
      ordersByType: null,
      kitchenLoad: null,
      restaurantPerformance: [],
      riderSLA: [],
    );
  }
}
