import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:equatable/equatable.dart';

abstract class KitchenEvent extends Equatable {
  const KitchenEvent();

  @override
  List<Object?> get props => [];
}

/// Load kitchen orders
class LoadKitchenOrders extends KitchenEvent {
  final String? station;
  final bool isSilent;

  const LoadKitchenOrders({this.station, this.isSilent = false});

  @override
  List<Object?> get props => [station, isSilent];
}

/// Filter orders by station
class FilterByStation extends KitchenEvent {
  final String station;

  const FilterByStation(this.station);

  @override
  List<Object?> get props => [station];
}

/// Start preparing an order (pending -> processing)
class StartOrderPrep extends KitchenEvent {
  final String orderId;

  const StartOrderPrep(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Mark order as ready (processing -> ready)
class MarkOrderReady extends KitchenEvent {
  final String orderId;

  const MarkOrderReady(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Update a specific task status
class UpdateTaskStatus extends KitchenEvent {
  final String taskId;
  final String status;

  const UpdateTaskStatus({required this.taskId, required this.status});

  @override
  List<Object?> get props => [taskId, status];
}

/// Handle a task update from WebSocket
class OnTaskUpdated extends KitchenEvent {
  final Map<String, dynamic> data;

  const OnTaskUpdated(this.data);

  @override
  List<Object?> get props => [data];
}

/// Handle a kitchen status update from WebSocket
class OnKitchenStatusUpdated extends KitchenEvent {
  final KitchenStatusModel status;

  const OnKitchenStatusUpdated(this.status);

  @override
  List<Object?> get props => [status];
}

/// Refresh kitchen orders
class RefreshKitchenOrders extends KitchenEvent {
  const RefreshKitchenOrders();
}

/// Load kitchen stats
class LoadKitchenStats extends KitchenEvent {
  const LoadKitchenStats();
}

/// Mark order as picked (clears from pickup list)
class MarkOrderPicked extends KitchenEvent {
  final String orderId;

  const MarkOrderPicked(this.orderId);

  @override
  List<Object?> get props => [orderId];
}
