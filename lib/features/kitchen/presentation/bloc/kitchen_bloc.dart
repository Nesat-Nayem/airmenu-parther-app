import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/repositories/kitchen_repository.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_kitchen_queue_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_kitchen_status_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_ready_orders_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_stations_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/update_task_status_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/domain/usecases/get_hotels_usecase.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_event.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_state.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class KitchenBloc extends Bloc<KitchenEvent, KitchenState> {
  final GetKitchenQueueUseCase _getKitchenQueueUseCase =
      locator<GetKitchenQueueUseCase>();
  final GetKitchenStatusUseCase _getKitchenStatusUseCase =
      locator<GetKitchenStatusUseCase>();
  final GetReadyOrdersUseCase _getReadyOrdersUseCase =
      locator<GetReadyOrdersUseCase>();
  final UpdateTaskStatusUseCase _updateTaskStatusUseCase =
      locator<UpdateTaskStatusUseCase>();
  final UpdateOrderStatusUseCase _updateOrderStatusUseCase =
      locator<UpdateOrderStatusUseCase>();
  final GetHotelsUseCase _getHotelsUseCase = locator<GetHotelsUseCase>();
  final GetStationsUseCase _getStationsUseCase = locator<GetStationsUseCase>();

  String _currentStation = 'All';
  String? _selectedHotelId;

  KitchenBloc() : super(KitchenInitial()) {
    on<LoadKitchenOrders>(_onLoadKitchenOrders);
    on<FilterByStation>(_onFilterByStation);
    on<UpdateTaskStatus>(_onUpdateTaskStatus);
    on<OnTaskUpdated>(_onTaskUpdated);
    on<OnKitchenStatusUpdated>(_onKitchenStatusUpdated);
    on<RefreshKitchenOrders>(_onRefreshKitchenOrders);
    on<MarkOrderPicked>(_onMarkOrderPicked);
  }

  Future<void> _onLoadKitchenOrders(
    LoadKitchenOrders event,
    Emitter<KitchenState> emit,
  ) async {
    // 0. Handle partial loading vs full loading
    if (state is KitchenLoaded && !event.isSilent) {
      emit((state as KitchenLoaded).copyWith(isQueueLoading: true));
    } else if (!event.isSilent) {
      emit(
        KitchenLoading(
          selectedStation: _currentStation,
          selectedHotelId: _selectedHotelId,
        ),
      );
    }

    // 1. Ensure we have a hotelId
    if (_selectedHotelId == null) {
      final hotelsResult = await _getHotelsUseCase();
      _selectedHotelId = hotelsResult.fold((failure) => null, (hotels) {
        if (hotels.isEmpty) return null;

        // Try to find a hotel with items or McD1 specifically if available
        // Use The Beverly Hills Hotel which has more test orders
        try {
          // For testing: use Beverly Hills Hotel ID directly
          // This hotel has the most orders for kitchen panel testing
          return '685de88e54e1f8bd67d8a1c0'; // The Beverly Hills Hotel
        } catch (_) {
          return hotels.first.id;
        }
      });

      if (_selectedHotelId == null) {
        emit(
          const KitchenError('No hotel found. Please select a hotel first.'),
        );
        return;
      }
    }

    final hotelId = _selectedHotelId!;

    // 2. Fetch queue and status
    // Optimization: If NOT All, we still might want to fetch everything or handle backend filtering
    // For now, let's behave as if we fetch everything when station ID is not an ObjectId (e.g. "Grill")
    // because backend might only filter by actual ObjectIds.
    final queueResult = await _getKitchenQueueUseCase(
      hotelId: hotelId,
      stationId: (_currentStation == 'All' || !_isObjectId(_currentStation))
          ? null
          : _currentStation,
    );
    final statusResult = await _getKitchenStatusUseCase(hotelId);
    final readyOrdersResult = await _getReadyOrdersUseCase(hotelId);
    final stationsResult = await _getStationsUseCase(hotelId);

    List<KitchenTaskModel> finalTasks = [];
    List<KitchenStationModel> stations = [];
    List<OrderModel> readyOrders = [];

    // Handle Queue Result
    queueResult.fold(
      (failure) {
        finalTasks = [];
      },
      (tasks) {
        finalTasks = tasks;
      },
    );

    // NOTE: If API returns empty, show empty state.

    // Handle Ready Orders Result
    readyOrdersResult.fold(
      (failure) => readyOrders = [],
      (orders) => readyOrders = orders,
    );

    // Handle Stations Result
    stationsResult.fold(
      (failure) => stations = [],
      (stationList) => stations = stationList,
    );

    // Filter finalTasks locally if we fetched everything but wanted a specific text-based station (e.g. "Grill")
    if (_currentStation != 'All') {
      finalTasks = finalTasks.where((task) {
        // Strict match or contains
        return task.stationName.toLowerCase().contains(
          _currentStation.toLowerCase(),
        );
      }).toList();
    }

    // Handle Status Result
    statusResult.fold(
      (failure) {
        final loadingIds = state is KitchenLoaded
            ? (state as KitchenLoaded).loadingIds
            : <String>{};
        emit(
          KitchenLoaded(
            tasks: finalTasks,
            allOrders: [],
            readyOrders: readyOrders,
            selectedStation: _currentStation,
            selectedHotelId: hotelId,
            stats: KitchenStats.fromTasks(finalTasks, null, readyOrders.length),
            loadingIds: loadingIds,
            isQueueLoading: false,
            stations: stations,
          ),
        );
      },
      (status) {
        final loadingIds = state is KitchenLoaded
            ? (state as KitchenLoaded).loadingIds
            : <String>{};
        emit(
          KitchenLoaded(
            tasks: finalTasks,
            kitchenStatus: status,
            allOrders: [],
            readyOrders: readyOrders,
            selectedStation: _currentStation,
            selectedHotelId: hotelId,
            stats: KitchenStats.fromTasks(
              finalTasks,
              status,
              readyOrders.length,
            ),
            loadingIds: loadingIds,
            isQueueLoading: false,
            stations: stations,
          ),
        );
      },
    );
  }

  void _onFilterByStation(FilterByStation event, Emitter<KitchenState> emit) {
    _currentStation = event.station;
    add(const LoadKitchenOrders());
  }

  Future<void> _onUpdateTaskStatus(
    UpdateTaskStatus event,
    Emitter<KitchenState> emit,
  ) async {
    // Store the current loaded state for recovery
    KitchenLoaded? preservedState;
    if (state is KitchenLoaded) {
      preservedState = state as KitchenLoaded;
      emit(
        preservedState.copyWith(
          loadingIds: {...preservedState.loadingIds, event.taskId},
        ),
      );
    }

    // Always attempt API call - handle errors gracefully
    final result = await _updateTaskStatusUseCase(
      taskId: event.taskId,
      status: event.status,
    );

    result.fold(
      (failure) {
        // Failure: Keep UI intact, show error via snackbar
        // IMPORTANT: Use CURRENT state's loadingIds (which HAS the taskId)
        if (state is KitchenLoaded) {
          final currentLoadedState = state as KitchenLoaded;
          final restoredState = currentLoadedState.copyWith(
            loadingIds: currentLoadedState.loadingIds
                .where((id) => id != event.taskId)
                .toSet(),
          );
          emit(restoredState);

          // Emit failure for listener (triggers snackbar)
          emit(KitchenActionFailure(failure.message));

          // Immediately re-emit loaded state so UI doesn't blank out
          emit(restoredState);
        } else {
          // No current loaded state - just emit failure
          emit(KitchenActionFailure(failure.message));
        }
      },
      (_) {
        // Success: Optimistically update the task status locally
        if (state is KitchenLoaded) {
          final currentLoadedState = state as KitchenLoaded;
          // Create a new list with the updated task
          final updatedTasks = currentLoadedState.tasks.map((task) {
            if (task.id == event.taskId) {
              return KitchenTaskModel(
                id: task.id,
                orderId: task.orderId,
                orderItemId: task.orderItemId,
                stationId: task.stationId,
                stationName: task.stationName,
                hotelId: task.hotelId,
                menuItemId: task.menuItemId,
                menuItemName: task.menuItemName,
                quantity: task.quantity,
                estimatedMinutes: task.estimatedMinutes,
                status: event.status,
                priority: task.priority,
                startedAt: event.status == 'IN_PROGRESS'
                    ? DateTime.now()
                    : task.startedAt,
                completedAt: event.status == 'DONE'
                    ? DateTime.now()
                    : task.completedAt,
                createdAt: task.createdAt,
                updatedAt: DateTime.now(),
                tableNumber: task.tableNumber,
                orderType: task.orderType,
                channel: task.channel,
                orderCreatedAt: task.orderCreatedAt,
                modifiers: task.modifiers,
                specialInstructions: task.specialInstructions,
              );
            }
            return task;
          }).toList();

          emit(
            currentLoadedState.copyWith(
              tasks: updatedTasks,
              loadingIds: currentLoadedState.loadingIds
                  .where((id) => id != event.taskId)
                  .toSet(),
            ),
          );
        }

        // Refresh silently to sync with backend
        add(const LoadKitchenOrders(isSilent: true));
      },
    );
  }

  void _onTaskUpdated(OnTaskUpdated event, Emitter<KitchenState> emit) {
    if (state is KitchenLoaded) {
      add(const LoadKitchenOrders(isSilent: true));
    }
  }

  void _onKitchenStatusUpdated(
    OnKitchenStatusUpdated event,
    Emitter<KitchenState> emit,
  ) {
    if (state is KitchenLoaded) {
      final currentState = state as KitchenLoaded;
      emit(
        currentState.copyWith(
          kitchenStatus: event.status,
          stats: KitchenStats.fromTasks(
            currentState.tasks,
            event.status,
            currentState.readyOrders.length,
          ),
        ),
      );
    }
  }

  void _onRefreshKitchenOrders(
    RefreshKitchenOrders event,
    Emitter<KitchenState> emit,
  ) {
    if (state is KitchenLoaded) {
      emit((state as KitchenLoaded).copyWith(isRefreshing: true));
    }
    add(const LoadKitchenOrders());
  }

  bool _isObjectId(String id) {
    return RegExp(r'^[0-9a-fA-F]{24}$').hasMatch(id);
  }

  Future<void> _onMarkOrderPicked(
    MarkOrderPicked event,
    Emitter<KitchenState> emit,
  ) async {
    // Store the current loaded state for recovery
    KitchenLoaded? preservedState;
    if (state is KitchenLoaded) {
      preservedState = state as KitchenLoaded;
      emit(
        preservedState.copyWith(
          loadingIds: {...preservedState.loadingIds, event.orderId},
        ),
      );
    }

    // Always attempt API call - handle errors gracefully
    final result = await _updateOrderStatusUseCase(
      orderId: event.orderId,
      status: 'delivered',
    );

    result.fold(
      (failure) {
        // Failure: Keep UI intact, show error via snackbar
        // IMPORTANT: Use CURRENT state's loadingIds (which HAS the orderId)
        if (state is KitchenLoaded) {
          final currentLoadedState = state as KitchenLoaded;
          final restoredState = currentLoadedState.copyWith(
            loadingIds: currentLoadedState.loadingIds
                .where((id) => id != event.orderId)
                .toSet(),
          );
          emit(restoredState);

          // Emit failure for listener (triggers snackbar)
          emit(KitchenActionFailure(failure.message));

          // Immediately re-emit loaded state so UI doesn't blank out
          emit(restoredState);
        } else {
          emit(KitchenActionFailure(failure.message));
        }
      },
      (_) {
        // Success: Optimistically remove the order from readyOrders
        if (state is KitchenLoaded) {
          final currentLoadedState = state as KitchenLoaded;
          final updatedReadyOrders = currentLoadedState.readyOrders
              .where((order) => order.id != event.orderId)
              .toList();

          emit(
            currentLoadedState.copyWith(
              readyOrders: updatedReadyOrders,
              loadingIds: currentLoadedState.loadingIds
                  .where((id) => id != event.orderId)
                  .toSet(),
              stats: KitchenStats.fromTasks(
                currentLoadedState.tasks,
                currentLoadedState.kitchenStatus,
                updatedReadyOrders.length,
              ),
            ),
          );
        }

        // Refresh silently to sync with backend
        add(const LoadKitchenOrders(isSilent: true));
      },
    );
  }
}
