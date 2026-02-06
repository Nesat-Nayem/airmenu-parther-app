import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {
  final String? status;

  /// When true, skip emitting OrdersLoading to prevent full page reload
  final bool isFiltering;

  const LoadOrders({this.status, this.isFiltering = false});

  @override
  List<Object?> get props => [status, isFiltering];
}

class FilterByStatus extends OrdersEvent {
  final String status;

  const FilterByStatus(this.status);

  @override
  List<Object?> get props => [status];
}

class FilterByPayment extends OrdersEvent {
  final String paymentStatus;

  const FilterByPayment(this.paymentStatus);

  @override
  List<Object?> get props => [paymentStatus];
}

class ChangePage extends OrdersEvent {
  final int page;

  const ChangePage(this.page);

  @override
  List<Object?> get props => [page];
}

/// Event for loading more orders (infinite scroll)
class LoadMoreOrders extends OrdersEvent {
  const LoadMoreOrders();
}

class UpdateOrderStatus extends OrdersEvent {
  final String orderId;
  final String newStatus;

  const UpdateOrderStatus({required this.orderId, required this.newStatus});

  @override
  List<Object?> get props => [orderId, newStatus];
}

class ProcessRefund extends OrdersEvent {
  final String orderId;
  final double amount;
  final String method;
  final String? reason;

  const ProcessRefund({
    required this.orderId,
    required this.amount,
    required this.method,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, amount, method, reason];
}

class RecordManualPayment extends OrdersEvent {
  final String orderId;
  final double amount;

  const RecordManualPayment({required this.orderId, required this.amount});

  @override
  List<Object?> get props => [orderId, amount];
}

class MarkOrderComplete extends OrdersEvent {
  final String orderId;

  const MarkOrderComplete({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class UpdateItemStatus extends OrdersEvent {
  final String orderId;
  final String itemId;
  final String status;

  const UpdateItemStatus({
    required this.orderId,
    required this.itemId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, itemId, status];
}

/// Toggle between grid and list view modes
class ToggleViewMode extends OrdersEvent {
  final bool isGridView;

  const ToggleViewMode(this.isGridView);

  @override
  List<Object?> get props => [isGridView];
}

/// Search orders by query
class SearchOrders extends OrdersEvent {
  final String query;

  const SearchOrders(this.query);

  @override
  List<Object?> get props => [query];
}

/// Refresh orders list
class RefreshOrders extends OrdersEvent {
  const RefreshOrders();
}

/// Toggle between grid and list view (no param, just toggles)
class ToggleView extends OrdersEvent {
  const ToggleView();
}
