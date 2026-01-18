import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_stats_model.dart';
import 'package:airmenuai_partner_app/core/models/pagination_model.dart';
import 'package:equatable/equatable.dart';

abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {
  final String? selectedStatus;
  final String? selectedPaymentStatus;

  const OrdersLoading({this.selectedStatus, this.selectedPaymentStatus});

  @override
  List<Object?> get props => [selectedStatus, selectedPaymentStatus];
}

class OrdersLoaded extends OrdersState {
  /// Orders for the list/Kanban (can be filtered)
  final List<OrderModel> orders;

  /// ALL orders for tiles (never filtered)
  final List<OrderModel> allOrders;
  final PaginationModel pagination;
  final int currentPage;
  final String? selectedStatus;
  final String? selectedPaymentStatus;
  final bool isGridView;
  final String searchQuery;

  /// True when refresh is in progress
  final bool isRefreshing;

  /// Order statistics from API (for dynamic filter counts and comparison badges)
  final OrderStatsModel? orderStats;

  const OrdersLoaded({
    required this.orders,
    required this.pagination,
    required this.currentPage,
    this.allOrders = const [],
    this.selectedStatus,
    this.selectedPaymentStatus,
    this.isGridView = true,
    this.searchQuery = '',
    this.isRefreshing = false,
    this.orderStats,
  });

  bool get canGoNext => currentPage < (pagination.totalPages ?? 1);
  bool get canGoPrevious => currentPage > 1;

  /// Calculate status counts from ALL orders (for tiles)
  Map<String, int> get tileCounts {
    final source = allOrders.isNotEmpty ? allOrders : orders;
    final counts = <String, int>{
      'all': source.length,
      'pending': 0,
      'processing': 0,
      'ready': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (final order in source) {
      final status = order.status?.toLowerCase() ?? 'pending';
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }

    return counts;
  }

  /// Calculate status counts from filtered orders (for filter tabs)
  Map<String, int> get statusCounts {
    final counts = <String, int>{
      'all': orders.length,
      'pending': 0,
      'processing': 0,
      'ready': 0,
      'delivered': 0,
      'cancelled': 0,
    };

    for (final order in orders) {
      final status = order.status?.toLowerCase() ?? 'pending';
      if (counts.containsKey(status)) {
        counts[status] = counts[status]! + 1;
      }
    }

    return counts;
  }

  /// Get filtered orders based on search query
  List<OrderModel> get filteredOrders {
    if (searchQuery.isEmpty) return orders;

    final query = searchQuery.toLowerCase();
    return orders.where((order) {
      final orderId = order.id?.toLowerCase() ?? '';
      final tableNumber = order.tableNumber?.toLowerCase() ?? '';
      final userName = order.users?.firstOrNull?.name?.toLowerCase() ?? '';

      return orderId.contains(query) ||
          tableNumber.contains(query) ||
          userName.contains(query);
    }).toList();
  }

  OrdersLoaded copyWith({
    List<OrderModel>? orders,
    List<OrderModel>? allOrders,
    PaginationModel? pagination,
    int? currentPage,
    String? selectedStatus,
    String? selectedPaymentStatus,
    bool? isGridView,
    String? searchQuery,
    bool? isRefreshing,
    OrderStatsModel? orderStats,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      allOrders: allOrders ?? this.allOrders,
      pagination: pagination ?? this.pagination,
      currentPage: currentPage ?? this.currentPage,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedPaymentStatus:
          selectedPaymentStatus ?? this.selectedPaymentStatus,
      isGridView: isGridView ?? this.isGridView,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      orderStats: orderStats ?? this.orderStats,
    );
  }

  @override
  List<Object?> get props => [
    orders,
    allOrders,
    pagination,
    currentPage,
    selectedStatus,
    selectedPaymentStatus,
    isGridView,
    searchQuery,
    isRefreshing,
    orderStats,
  ];
}

class OrdersEmpty extends OrdersState {
  final String? selectedStatus;
  final String? selectedPaymentStatus;

  const OrdersEmpty({this.selectedStatus, this.selectedPaymentStatus});

  @override
  List<Object?> get props => [selectedStatus, selectedPaymentStatus];
}

class OrdersError extends OrdersState {
  final String message;

  const OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}

class OrderStatusUpdateSuccess extends OrdersState {
  const OrderStatusUpdateSuccess();
}

class OrderStatusUpdateFailure extends OrdersState {
  final String message;

  const OrderStatusUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Refund States
class RefundProcessing extends OrdersState {
  const RefundProcessing();
}

class RefundSuccess extends OrdersState {
  const RefundSuccess();
}

class RefundFailure extends OrdersState {
  final String message;

  const RefundFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Manual Payment States
class ManualPaymentProcessing extends OrdersState {
  const ManualPaymentProcessing();
}

class ManualPaymentSuccess extends OrdersState {
  const ManualPaymentSuccess();
}

class ManualPaymentFailure extends OrdersState {
  final String message;

  const ManualPaymentFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Mark Complete States
class MarkCompleteProcessing extends OrdersState {
  const MarkCompleteProcessing();
}

class MarkCompleteSuccess extends OrdersState {
  const MarkCompleteSuccess();
}

class MarkCompleteFailure extends OrdersState {
  final String message;

  const MarkCompleteFailure(this.message);

  @override
  List<Object?> get props => [message];
}

// Item Status Update States
class ItemStatusUpdating extends OrdersState {
  const ItemStatusUpdating();
}

class ItemStatusUpdateSuccess extends OrdersState {
  const ItemStatusUpdateSuccess();
}

class ItemStatusUpdateFailure extends OrdersState {
  final String message;

  const ItemStatusUpdateFailure(this.message);

  @override
  List<Object?> get props => [message];
}
