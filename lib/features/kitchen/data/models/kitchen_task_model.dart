import 'package:equatable/equatable.dart';

class KitchenTaskModel extends Equatable {
  final String id;
  final String orderId;
  final String orderItemId;
  final String stationId;
  final String stationName;
  final String hotelId;
  final String menuItemId;
  final String menuItemName;
  final int quantity;
  final double estimatedMinutes;
  final String status; // QUEUED, IN_PROGRESS, DONE, CANCELLED
  final int priority;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Flattened order details for UI convenience
  final String? tableNumber;
  final String? orderType;
  final String? channel;
  final DateTime? orderCreatedAt;
  final List<String>? modifiers;
  final String? specialInstructions;

  const KitchenTaskModel({
    required this.id,
    required this.orderId,
    required this.orderItemId,
    required this.stationId,
    required this.stationName,
    required this.hotelId,
    required this.menuItemId,
    required this.menuItemName,
    required this.quantity,
    required this.estimatedMinutes,
    required this.status,
    required this.priority,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tableNumber,
    this.orderType,
    this.channel,
    this.orderCreatedAt,
    this.modifiers,
    this.specialInstructions,
  });

  factory KitchenTaskModel.fromJson(Map<String, dynamic> json) {
    // Handle population if present
    final orderJson = json['orderId'] is Map ? json['orderId'] : null;

    DateTime? safelyParseDateTime(String? dateStr) {
      if (dateStr == null || dateStr.toLowerCase().contains('invalid')) {
        return null;
      }
      try {
        return DateTime.parse(dateStr);
      } catch (_) {
        // If standard parse fails, try to handle "26/12/2025, 12:43:22 am"
        // But for a robust fix, we just return null or a default
        return null;
      }
    }

    return KitchenTaskModel(
      id: json['_id'] ?? '',
      orderId: orderJson != null ? orderJson['_id'] : (json['orderId'] ?? ''),
      orderItemId: json['orderItemId'] ?? '',
      stationId: json['stationId'] ?? '',
      stationName: json['stationName'] ?? '',
      hotelId: json['hotelId'] ?? '',
      menuItemId: json['menuItemId'] ?? '',
      menuItemName: json['menuItemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      estimatedMinutes: (json['estimatedMinutes'] ?? 0).toDouble(),
      status: json['status'] ?? 'QUEUED',
      priority: json['priority'] ?? 0,
      startedAt: safelyParseDateTime(json['startedAt']),
      completedAt: safelyParseDateTime(json['completedAt']),
      createdAt: safelyParseDateTime(json['createdAt']) ?? DateTime.now(),
      updatedAt:
          safelyParseDateTime(json['updatedAt'] ?? json['createdAt']) ??
          DateTime.now(),
      tableNumber: orderJson?['tableNumber'],
      orderType: orderJson?['orderType'],
      channel: orderJson?['channel'],
      orderCreatedAt: safelyParseDateTime(orderJson?['createdAt']),
      modifiers: json['modifiers'] != null
          ? List<String>.from(json['modifiers'])
          : null,
      specialInstructions: json['specialInstructions'],
    );
  }

  @override
  List<Object?> get props => [
    id,
    status,
    priority,
    startedAt,
    completedAt,
    updatedAt,
  ];
}

class KitchenStatusModel extends Equatable {
  final String hotelId;
  final String overallStatus;
  final bool canAcceptOrders;
  final int estimatedWaitMinutes;
  final List<StationStatusModel> stations;
  final List<String> disabledItems;
  final String message;
  final DateTime lastUpdated;

  const KitchenStatusModel({
    required this.hotelId,
    required this.overallStatus,
    required this.canAcceptOrders,
    required this.estimatedWaitMinutes,
    required this.stations,
    required this.disabledItems,
    required this.message,
    required this.lastUpdated,
  });

  factory KitchenStatusModel.fromJson(Map<String, dynamic> json) {
    return KitchenStatusModel(
      hotelId: json['hotelId'] ?? '',
      overallStatus: json['overallStatus'] ?? 'NORMAL',
      canAcceptOrders: json['canAcceptOrders'] ?? true,
      estimatedWaitMinutes: json['estimatedWaitMinutes'] ?? 0,
      stations: (json['stations'] as List? ?? [])
          .map((s) => StationStatusModel.fromJson(s))
          .toList(),
      disabledItems: List<String>.from(json['disabledItems'] ?? []),
      message: json['message'] ?? '',
      lastUpdated: DateTime.parse(
        json['lastUpdated'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  @override
  List<Object?> get props => [overallStatus, estimatedWaitMinutes, stations];
}

class StationStatusModel extends Equatable {
  final String stationId;
  final String stationCode;
  final String stationName;
  final String status;
  final int currentLoadMinutes;
  final int queuedTasks;
  final int inProgressTasks;

  const StationStatusModel({
    required this.stationId,
    required this.stationCode,
    required this.stationName,
    required this.status,
    required this.currentLoadMinutes,
    required this.queuedTasks,
    required this.inProgressTasks,
  });

  factory StationStatusModel.fromJson(Map<String, dynamic> json) {
    return StationStatusModel(
      stationId: json['stationId'] ?? '',
      stationCode: json['stationCode'] ?? '',
      stationName: json['stationName'] ?? '',
      status: json['status'] ?? 'NORMAL',
      currentLoadMinutes: json['currentLoadMinutes'] ?? 0,
      queuedTasks: json['queuedTasks'] ?? 0,
      inProgressTasks: json['inProgressTasks'] ?? 0,
    );
  }

  @override
  List<Object?> get props => [
    stationId,
    status,
    currentLoadMinutes,
    queuedTasks,
    inProgressTasks,
  ];
}
