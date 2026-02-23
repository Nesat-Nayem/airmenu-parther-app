import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_stats_model.dart';
import 'package:airmenuai_partner_app/features/orders/domain/usecases/get_orders_usecase.dart';
import 'package:airmenuai_partner_app/features/orders/domain/usecases/update_order_status_usecase.dart';
import 'package:airmenuai_partner_app/features/orders/domain/repositories/orders_repository.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/core/models/pagination_model.dart';
import 'package:airmenuai_partner_app/core/error/failure.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  String _currentStatus = 'All Status';
  String _currentPaymentStatus = 'All Payments';
  bool _isGridView = true;
  String _searchQuery = '';

  /// Cached order stats from API
  OrderStatsModel? _cachedOrderStats;

  OrdersBloc() : super(OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<LoadMoreOrders>(_onLoadMoreOrders);
    on<FilterByStatus>(_onFilterByStatus);
    on<FilterByPayment>(_onFilterByPayment);
    on<ChangePage>(_onChangePage);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<ProcessRefund>(_onProcessRefund);
    on<RecordManualPayment>(_onRecordManualPayment);
    on<MarkOrderComplete>(_onMarkOrderComplete);
    on<UpdateItemStatus>(_onUpdateItemStatus);
    on<ToggleViewMode>(_onToggleViewMode);
    on<ToggleView>(_onToggleView);
    on<SearchOrders>(_onSearchOrders);
    on<RefreshOrders>(_onRefreshOrders);
    on<FilterByRestaurant>(_onFilterByRestaurant);
  }

  /// Stores ALL orders from initial unfiltered load (for tiles)
  List<OrderModel> _allOrders = [];

  /// Cached branch map: hotelId -> hotelName
  Map<String, String> _branchMap = {};

  /// Enrich orders with hotel names from the branch map
  List<OrderModel> _enrichOrdersWithHotelNames(List<OrderModel> orders) {
    if (_branchMap.isEmpty) return orders;
    return orders.map((order) {
      // Skip if already has a hotel name
      if (order.hotelName != null && order.hotelName!.isNotEmpty) return order;

      final hId = order.hotelId ?? order.hotel?.id ?? order.items?.firstOrNull?.hotelId;
      if (hId != null && _branchMap.containsKey(hId)) {
        return order.withHotelInfo(hotelName: _branchMap[hId], hotelId: hId);
      }
      return order;
    }).toList();
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    // Preserve allOrders if we already have them
    final preservedAllOrders = _allOrders;

    // Only emit loading state for initial load, not for filtering
    if (!event.isFiltering) {
      emit(
        OrdersLoading(
          selectedStatus: _currentStatus,
          selectedPaymentStatus: _currentPaymentStatus,
        ),
      );
    }

    // Fetch orders and stats in parallel
    final ordersResult = await locator<GetOrdersUseCase>()(
      status: event.status ?? _currentStatus,
      paymentStatus: _currentPaymentStatus != 'All Payments'
          ? _currentPaymentStatus
          : null,
    );

    // Fetch order stats and branches in parallel
    final statsResult = await locator<OrdersRepository>().getOrderStats();
    statsResult.fold(
      (failure) {
        _cachedOrderStats = null;
      },
      (stats) {
        _cachedOrderStats = stats;
      },
    );

    // Fetch branches for hotel name resolution
    if (_branchMap.isEmpty) {
      final branchesResult = await locator<OrdersRepository>().getBranches();
      branchesResult.fold(
        (failure) {},
        (branches) {
          _branchMap = {for (final b in branches) b.id: b.name};
        },
      );
    }

    ordersResult.fold(
      (error) {
        String message = 'Unknown error';
        if (error is ServerFailure) {
          message = error.message;
        }
        emit(OrdersError(message));
      },
      (response) {
        if (response.data == null || response.data!.isEmpty) {
          emit(
            OrdersEmpty(
              selectedStatus: _currentStatus,
              selectedPaymentStatus: _currentPaymentStatus,
            ),
          );
        } else {
          // Enrich orders with hotel names from branch map
          final enrichedOrders = _enrichOrdersWithHotelNames(response.data!);

          // If this is initial load (no filter), save ALL orders for tiles
          final isInitialLoad =
              event.status == null ||
              event.status == 'All Status' ||
              event.status?.toLowerCase() == 'all';

          if (isInitialLoad) {
            _allOrders = enrichedOrders;
          }

          emit(
            OrdersLoaded(
              orders: enrichedOrders,
              allOrders: preservedAllOrders.isNotEmpty
                  ? preservedAllOrders
                  : _allOrders,
              // Pagination placeholder - to be implemented later
              pagination:
                  response.pagination ??
                  PaginationModel(
                    totalItems: enrichedOrders.length,
                    currentPage: 1,
                    itemsPerPage: enrichedOrders.length,
                    totalPages: 1,
                  ),
              currentPage: 1,
              selectedStatus: _currentStatus,
              selectedPaymentStatus: _currentPaymentStatus,
              isGridView: _isGridView,
              searchQuery: _searchQuery,
              orderStats: _cachedOrderStats,
            ),
          );
        }
      },
    );
  }

  /// Handle loading more orders for infinite scroll
  Future<void> _onLoadMoreOrders(
    LoadMoreOrders event,
    Emitter<OrdersState> emit,
  ) async {
    final currentState = state;
    if (currentState is! OrdersLoaded) return;

    // Don't load more if already loading or reached max
    if (currentState.isLoadingMore || currentState.hasReachedMax) return;

    // Emit loading more state
    emit(currentState.copyWith(isLoadingMore: true));

    final nextPage = currentState.currentPage + 1;

    final result = await locator<GetOrdersUseCase>()(
      status: _currentStatus,
      paymentStatus: _currentPaymentStatus != 'All Payments'
          ? _currentPaymentStatus
          : null,
      page: nextPage,
      limit: 20,
    );

    result.fold(
      (failure) {
        // Failed to load more, reset loading state
        emit(currentState.copyWith(isLoadingMore: false));
      },
      (response) {
        final newOrders = _enrichOrdersWithHotelNames(response.data ?? []);
        final hasReachedMax =
            newOrders.isEmpty ||
            nextPage >= (response.pagination?.totalPages ?? 1);

        emit(
          currentState.copyWith(
            orders: [...currentState.orders, ...newOrders],
            pagination: response.pagination ?? currentState.pagination,
            currentPage: nextPage,
            isLoadingMore: false,
            hasReachedMax: hasReachedMax,
          ),
        );
      },
    );
  }

  void _onFilterByStatus(FilterByStatus event, Emitter<OrdersState> emit) {
    _currentStatus = event.status;

    // In-memory filtering from allOrders (no API call)
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      final allOrders = currentState.allOrders;

      // Show loading briefly
      emit(currentState.copyWith(isRefreshing: true));

      List<OrderModel> filteredOrders;
      if (event.status == 'All Status' || event.status.toLowerCase() == 'all') {
        filteredOrders = allOrders;
      } else {
        filteredOrders = allOrders
            .where(
              (order) =>
                  order.status?.toLowerCase() == event.status.toLowerCase(),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          orders: filteredOrders,
          selectedStatus: event.status,
          isRefreshing: false,
        ),
      );
    }
  }

  void _onFilterByPayment(FilterByPayment event, Emitter<OrdersState> emit) {
    _currentPaymentStatus = event.paymentStatus;
    add(const LoadOrders());
  }

  void _onChangePage(ChangePage event, Emitter<OrdersState> emit) {
    // Pagination removed for now - will be implemented later
    // Just reload orders without page parameter
    add(LoadOrders(status: _currentStatus));
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await locator<UpdateOrderStatusUseCase>().call(
      orderId: event.orderId,
      status: event.newStatus,
    );

    result.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to update order status';
        emit(OrderStatusUpdateFailure(errorMessage));
      },
      (_) {
        emit(const OrderStatusUpdateSuccess());
        add(LoadOrders(status: _currentStatus));
      },
    );
  }

  Future<void> _onProcessRefund(
    ProcessRefund event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const RefundProcessing());

    final result = await locator<OrdersRepository>().processRefund(
      orderId: event.orderId,
      amount: event.amount,
      method: event.method,
      reason: event.reason,
    );

    result.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to process refund';
        emit(RefundFailure(errorMessage));
      },
      (_) {
        emit(const RefundSuccess());
        add(LoadOrders(status: _currentStatus));
      },
    );
  }

  Future<void> _onRecordManualPayment(
    RecordManualPayment event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const ManualPaymentProcessing());

    final result = await locator<OrdersRepository>().recordManualPayment(
      orderId: event.orderId,
      amount: event.amount,
    );

    result.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to record payment';
        emit(ManualPaymentFailure(errorMessage));
      },
      (_) {
        emit(const ManualPaymentSuccess());
        add(LoadOrders(status: _currentStatus));
      },
    );
  }

  Future<void> _onMarkOrderComplete(
    MarkOrderComplete event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const MarkCompleteProcessing());

    final result = await locator<OrdersRepository>().markOrderComplete(
      orderId: event.orderId,
    );

    result.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to mark order complete';
        emit(MarkCompleteFailure(errorMessage));
      },
      (_) {
        emit(const MarkCompleteSuccess());
        add(LoadOrders(status: _currentStatus));
      },
    );
  }

  Future<void> _onUpdateItemStatus(
    UpdateItemStatus event,
    Emitter<OrdersState> emit,
  ) async {
    emit(const ItemStatusUpdating());

    final result = await locator<OrdersRepository>().updateItemStatus(
      orderId: event.orderId,
      itemId: event.itemId,
      status: event.status,
    );

    result.fold(
      (failure) {
        final errorMessage = failure is ServerFailure
            ? failure.message
            : 'Failed to update item status';
        emit(ItemStatusUpdateFailure(errorMessage));
      },
      (_) {
        emit(const ItemStatusUpdateSuccess());
        add(LoadOrders(status: _currentStatus));
      },
    );
  }

  void _onToggleViewMode(ToggleViewMode event, Emitter<OrdersState> emit) {
    _isGridView = event.isGridView;
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(isGridView: event.isGridView));
    }
  }

  void _onToggleView(ToggleView event, Emitter<OrdersState> emit) {
    _isGridView = !_isGridView;
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(isGridView: _isGridView));
    }
  }

  void _onSearchOrders(SearchOrders event, Emitter<OrdersState> emit) {
    _searchQuery = event.query;
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(searchQuery: event.query));
    }
  }

  void _onFilterByRestaurant(
    FilterByRestaurant event,
    Emitter<OrdersState> emit,
  ) {
    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      if (event.restaurantId == null) {
        emit(currentState.copyWith(clearRestaurantFilter: true));
      } else {
        emit(currentState.copyWith(selectedRestaurantId: event.restaurantId));
      }
    }
  }

  void _onRefreshOrders(RefreshOrders event, Emitter<OrdersState> emit) {
    // Set isRefreshing to show spinner
    if (state is OrdersLoaded) {
      emit((state as OrdersLoaded).copyWith(isRefreshing: true));
    }
    add(LoadOrders(status: _currentStatus));
  }
}
