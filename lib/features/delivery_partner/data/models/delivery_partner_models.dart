class DeliveryPartner {
  final String id;
  final String name;
  final String
  type; // 'Hyperlocal', 'Bike Delivery', 'Multi-mode', 'Heavy Delivery'
  final double costPerKm;
  final int avgTimeMinutes;
  final double slaScore; // 0-100
  final int activeRiders;
  final String coverage; // e.g., "12 cities"
  final int totalDeliveries;
  final String status; // 'active', 'inactive', 'pending'
  final String apiStatus; // 'connected', 'error', 'pending'
  final String? webhookUrl;
  final String? apiKey;
  final int? priorityOrder;
  final bool autoAssignOrders;
  final String? fallbackPartner;

  DeliveryPartner({
    required this.id,
    required this.name,
    required this.type,
    required this.costPerKm,
    required this.avgTimeMinutes,
    required this.slaScore,
    required this.activeRiders,
    required this.coverage,
    required this.totalDeliveries,
    required this.status,
    required this.apiStatus,
    this.webhookUrl,
    this.apiKey,
    this.priorityOrder,
    this.autoAssignOrders = false,
    this.fallbackPartner,
  });

  factory DeliveryPartner.fromJson(Map<String, dynamic> json) {
    return DeliveryPartner(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      costPerKm: (json['costPerKm'] as num).toDouble(),
      avgTimeMinutes: json['avgTimeMinutes'] as int,
      slaScore: (json['slaScore'] as num).toDouble(),
      activeRiders: json['activeRiders'] as int,
      coverage: json['coverage'] as String,
      totalDeliveries: json['totalDeliveries'] as int,
      status: json['status'] as String,
      apiStatus: json['apiStatus'] as String,
      webhookUrl: json['webhookUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      priorityOrder: json['priorityOrder'] as int?,
      autoAssignOrders: json['autoAssignOrders'] as bool? ?? false,
      fallbackPartner: json['fallbackPartner'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'costPerKm': costPerKm,
      'avgTimeMinutes': avgTimeMinutes,
      'slaScore': slaScore,
      'activeRiders': activeRiders,
      'coverage': coverage,
      'totalDeliveries': totalDeliveries,
      'status': status,
      'apiStatus': apiStatus,
      'webhookUrl': webhookUrl,
      'apiKey': apiKey,
      'priorityOrder': priorityOrder,
      'autoAssignOrders': autoAssignOrders,
      'fallbackPartner': fallbackPartner,
    };
  }

  DeliveryPartner copyWith({
    String? id,
    String? name,
    String? type,
    double? costPerKm,
    int? avgTimeMinutes,
    double? slaScore,
    int? activeRiders,
    String? coverage,
    int? totalDeliveries,
    String? status,
    String? apiStatus,
    String? webhookUrl,
    String? apiKey,
    int? priorityOrder,
    bool? autoAssignOrders,
    String? fallbackPartner,
  }) {
    return DeliveryPartner(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      costPerKm: costPerKm ?? this.costPerKm,
      avgTimeMinutes: avgTimeMinutes ?? this.avgTimeMinutes,
      slaScore: slaScore ?? this.slaScore,
      activeRiders: activeRiders ?? this.activeRiders,
      coverage: coverage ?? this.coverage,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      status: status ?? this.status,
      apiStatus: apiStatus ?? this.apiStatus,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      apiKey: apiKey ?? this.apiKey,
      priorityOrder: priorityOrder ?? this.priorityOrder,
      autoAssignOrders: autoAssignOrders ?? this.autoAssignOrders,
      fallbackPartner: fallbackPartner ?? this.fallbackPartner,
    );
  }
}

class DeliveryPartnerStats {
  final int totalPartners;
  final int activeRiders;
  final int avgDeliveryTimeMinutes;
  final double avgSlaScore;
  final int apiErrors;
  final String totalPartnersChange; // e.g., "+12%"
  final String activeRidersChange; // e.g., "vs yesterday"
  final String avgDeliveryTimeChange; // e.g., "-3%"
  final String avgSlaScoreChange; // e.g., "+2%"

  DeliveryPartnerStats({
    required this.totalPartners,
    required this.activeRiders,
    required this.avgDeliveryTimeMinutes,
    required this.avgSlaScore,
    required this.apiErrors,
    this.totalPartnersChange = '',
    this.activeRidersChange = 'vs yesterday',
    this.avgDeliveryTimeChange = '',
    this.avgSlaScoreChange = '',
  });

  factory DeliveryPartnerStats.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerStats(
      totalPartners: json['totalPartners'] as int,
      activeRiders: json['activeRiders'] as int,
      avgDeliveryTimeMinutes: json['avgDeliveryTimeMinutes'] as int,
      avgSlaScore: (json['avgSlaScore'] as num).toDouble(),
      apiErrors: json['apiErrors'] as int,
      totalPartnersChange: json['totalPartnersChange'] as String? ?? '',
      activeRidersChange:
          json['activeRidersChange'] as String? ?? 'vs yesterday',
      avgDeliveryTimeChange: json['avgDeliveryTimeChange'] as String? ?? '',
      avgSlaScoreChange: json['avgSlaScoreChange'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPartners': totalPartners,
      'activeRiders': activeRiders,
      'avgDeliveryTimeMinutes': avgDeliveryTimeMinutes,
      'avgSlaScore': avgSlaScore,
      'apiErrors': apiErrors,
      'totalPartnersChange': totalPartnersChange,
      'activeRidersChange': activeRidersChange,
      'avgDeliveryTimeChange': avgDeliveryTimeChange,
      'avgSlaScoreChange': avgSlaScoreChange,
    };
  }
}
