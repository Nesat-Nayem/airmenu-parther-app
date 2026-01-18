import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:equatable/equatable.dart';

abstract class KitchenState extends Equatable {
  const KitchenState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class KitchenInitial extends KitchenState {}

/// Loading kitchen orders
class KitchenLoading extends KitchenState {
  final String selectedStation;
  final String? selectedHotelId;

  const KitchenLoading({this.selectedStation = 'All', this.selectedHotelId});

  @override
  List<Object?> get props => [selectedStation, selectedHotelId];
}

/// Kitchen orders loaded successfully
class KitchenLoaded extends KitchenState {
  final List<KitchenTaskModel> tasks;
  final KitchenStatusModel? kitchenStatus;
  final String selectedStation;
  final String selectedHotelId;
  final KitchenStats stats;
  final bool isQueueLoading;
  final bool isRefreshing;

  // Keep allOrders for backward compatibility or if needed
  final List<OrderModel> allOrders;

  // Ready for Pickup orders
  final List<OrderModel> readyOrders;

  // Track which tasks or orders are currently being updated (localized loading)
  final Set<String> loadingIds;

  // Dynamic station list from API
  final List<KitchenStationModel> stations;

  const KitchenLoaded({
    required this.tasks,
    this.kitchenStatus,
    required this.allOrders,
    required this.readyOrders,
    required this.selectedStation,
    required this.selectedHotelId,
    required this.stats,
    this.isRefreshing = false,
    this.loadingIds = const {},
    this.isQueueLoading = false,
    this.stations = const [],
  });

  @override
  List<Object?> get props => [
    tasks,
    kitchenStatus,
    allOrders,
    readyOrders,
    selectedStation,
    selectedHotelId,
    stats,
    isRefreshing,
    loadingIds,
    isQueueLoading,
    stations,
  ];

  KitchenLoaded copyWith({
    List<KitchenTaskModel>? tasks,
    KitchenStatusModel? kitchenStatus,
    List<OrderModel>? allOrders,
    List<OrderModel>? readyOrders,
    String? selectedStation,
    String? selectedHotelId,
    KitchenStats? stats,
    bool? isRefreshing,
    Set<String>? loadingIds,
    bool? isQueueLoading,
    List<KitchenStationModel>? stations,
  }) {
    return KitchenLoaded(
      tasks: tasks ?? this.tasks,
      kitchenStatus: kitchenStatus ?? this.kitchenStatus,
      allOrders: allOrders ?? this.allOrders,
      readyOrders: readyOrders ?? this.readyOrders,
      selectedStation: selectedStation ?? this.selectedStation,
      selectedHotelId: selectedHotelId ?? this.selectedHotelId,
      stats: stats ?? this.stats,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadingIds: loadingIds ?? this.loadingIds,
      isQueueLoading: isQueueLoading ?? this.isQueueLoading,
      stations: stations ?? this.stations,
    );
  }

  /// Get tasks filtered for kitchen view (QUEUED + IN_PROGRESS)
  List<KitchenTaskModel> get kitchenTasks {
    return tasks.where((t) {
      final status = t.status.toUpperCase();
      return status == 'QUEUED' || status == 'IN_PROGRESS';
    }).toList();
  }

  /// Get tasks grouped by status for display
  Map<String, List<KitchenTaskModel>> get groupedTasks {
    final grouped = <String, List<KitchenTaskModel>>{};
    for (final task in kitchenTasks) {
      final status = task.status.toLowerCase();
      grouped.putIfAbsent(status, () => []);
      grouped[status]!.add(task);
    }
    return grouped;
  }
}

/// Kitchen stats model
class KitchenStats {
  final int activeStations;
  final int ordersInQueue;
  final int avgPrepTimeMinutes;
  final int readyForPickup;

  const KitchenStats({
    this.activeStations = 0,
    this.ordersInQueue = 0,
    this.avgPrepTimeMinutes = 0,
    this.readyForPickup = 0,
  });

  factory KitchenStats.fromTasks(
    List<KitchenTaskModel> tasks,
    KitchenStatusModel? status,
    int readyOrdersCount,
  ) {
    if (status != null) {
      return KitchenStats(
        activeStations: status.stations.length,
        ordersInQueue: status.stations.fold(0, (sum, s) => sum + s.queuedTasks),
        avgPrepTimeMinutes: status.estimatedWaitMinutes,
        readyForPickup: readyOrdersCount,
      );
    }

    // Fallback to calculation from tasks
    final activeStationSet = <String>{};
    int queuedCount = 0;
    int totalPrepTime = 0;
    int prepTaskCount = 0;

    for (final task in tasks) {
      final s = task.status.toUpperCase();
      if (s == 'QUEUED' || s == 'IN_PROGRESS') {
        queuedCount++;
        activeStationSet.add(task.stationId);
      }

      if (s == 'IN_PROGRESS' && task.startedAt != null) {
        final elapsed = DateTime.now().difference(task.startedAt!).inMinutes;
        totalPrepTime += elapsed;
        prepTaskCount++;
      }
    }

    return KitchenStats(
      activeStations: activeStationSet.length,
      ordersInQueue: queuedCount,
      avgPrepTimeMinutes: prepTaskCount > 0
          ? (totalPrepTime / prepTaskCount).round()
          : 0,
      readyForPickup: readyOrdersCount,
    );
  }
}

/// Error state
class KitchenError extends KitchenState {
  final String message;

  const KitchenError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Order prep started success
class OrderPrepStarted extends KitchenState {
  const OrderPrepStarted();
}

/// Order marked ready success
class OrderMarkedReady extends KitchenState {
  const OrderMarkedReady();
}

/// Action failure state
class KitchenActionFailure extends KitchenState {
  final String message;

  const KitchenActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
