import 'package:airmenuai_partner_app/features/inventory/data/models/inventory_models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class RefreshInventory extends InventoryEvent {}

class UpdateSearchQuery extends InventoryEvent {
  final String query;
  const UpdateSearchQuery(this.query);
  @override
  List<Object?> get props => [query];
}

class UpdateCategoryFilter extends InventoryEvent {
  final String category;
  const UpdateCategoryFilter(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateStatusFilter extends InventoryEvent {
  final String status;
  const UpdateStatusFilter(this.status);
  @override
  List<Object?> get props => [status];
}

class ToggleCompactView extends InventoryEvent {}

class ToggleAnalytics extends InventoryEvent {}

// State
class InventoryState extends Equatable {
  final bool isLoading;
  final List<InventoryItem> items;
  final List<PurchaseOrder> recentOrders;
  final InventoryAnalytics? analytics;
  final String searchQuery;
  final String categoryFilter;
  final String statusFilter;
  final bool isCompactView;
  final bool showAnalytics;
  final String? errorMessage;

  const InventoryState({
    this.isLoading = false,
    this.items = const [],
    this.recentOrders = const [],
    this.analytics,
    this.searchQuery = '',
    this.categoryFilter = 'All',
    this.statusFilter = 'All',
    this.isCompactView = false,
    this.showAnalytics = false,
    this.errorMessage,
  });

  List<InventoryItem> get filteredItems {
    var filtered = items;

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                item.category.toLowerCase().contains(searchQuery.toLowerCase()),
          )
          .toList();
    }

    // Apply category filter
    if (categoryFilter != 'All') {
      filtered = filtered
          .where((item) => item.category == categoryFilter)
          .toList();
    }

    // Apply status filter
    if (statusFilter != 'All') {
      filtered = filtered.where((item) {
        switch (statusFilter) {
          case 'Critical':
            return item.status == StockStatus.critical;
          case 'Low':
            return item.status == StockStatus.low;
          default:
            return true;
        }
      }).toList();
    }

    return filtered;
  }

  InventoryState copyWith({
    bool? isLoading,
    List<InventoryItem>? items,
    List<PurchaseOrder>? recentOrders,
    InventoryAnalytics? analytics,
    String? searchQuery,
    String? categoryFilter,
    String? statusFilter,
    bool? isCompactView,
    bool? showAnalytics,
    String? errorMessage,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      recentOrders: recentOrders ?? this.recentOrders,
      analytics: analytics ?? this.analytics,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      statusFilter: statusFilter ?? this.statusFilter,
      isCompactView: isCompactView ?? this.isCompactView,
      showAnalytics: showAnalytics ?? this.showAnalytics,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    items,
    recentOrders,
    analytics,
    searchQuery,
    categoryFilter,
    statusFilter,
    isCompactView,
    showAnalytics,
    errorMessage,
  ];
}

// Bloc
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  InventoryBloc() : super(const InventoryState()) {
    on<LoadInventory>(_onLoadInventory);
    on<RefreshInventory>(_onRefreshInventory);
    on<UpdateSearchQuery>(_onUpdateSearchQuery);
    on<UpdateCategoryFilter>(_onUpdateCategoryFilter);
    on<UpdateStatusFilter>(_onUpdateStatusFilter);
    on<ToggleCompactView>(_onToggleCompactView);
    on<ToggleAnalytics>(_onToggleAnalytics);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Mock Data
    final mockItems = [
      const InventoryItem(
        id: '1',
        name: 'Paneer',
        category: 'Dairy',
        currentStock: 2,
        minStock: 5,
        maxStock: 10,
        costPrice: 320,
        unit: 'kg',
        status: StockStatus.critical,
        consumption: ConsumptionLevel.high,
        vendor: 'Fresh Dairy Co.',
      ),
      const InventoryItem(
        id: '2',
        name: 'Chicken',
        category: 'Meat',
        currentStock: 8,
        minStock: 10,
        maxStock: 20,
        costPrice: 450,
        unit: 'kg',
        status: StockStatus.low,
        consumption: ConsumptionLevel.high,
        vendor: 'Farm Fresh Meats',
      ),
      const InventoryItem(
        id: '3',
        name: 'Basmati Rice',
        category: 'Grains',
        currentStock: 25,
        minStock: 20,
        maxStock: 50,
        costPrice: 120,
        unit: 'kg',
        status: StockStatus.healthy,
        consumption: ConsumptionLevel.medium,
        vendor: 'Grain Traders',
      ),
      const InventoryItem(
        id: '4',
        name: 'Fresh Cream',
        category: 'Dairy',
        currentStock: 3,
        minStock: 5,
        maxStock: 10,
        costPrice: 180,
        unit: 'L',
        status: StockStatus.low,
        consumption: ConsumptionLevel.high,
        vendor: 'Fresh Dairy Co.',
      ),
      const InventoryItem(
        id: '5',
        name: 'Onions',
        category: 'Vegetables',
        currentStock: 15,
        minStock: 10,
        maxStock: 30,
        costPrice: 40,
        unit: 'kg',
        status: StockStatus.healthy,
        consumption: ConsumptionLevel.high,
        vendor: 'Veggie Hub',
      ),
      const InventoryItem(
        id: '6',
        name: 'Cooking Oil',
        category: 'Oils',
        currentStock: 12,
        minStock: 10,
        maxStock: 20,
        costPrice: 150,
        unit: 'L',
        status: StockStatus.healthy,
        consumption: ConsumptionLevel.medium,
        vendor: 'Oil Mills Ltd.',
      ),
    ];

    final mockOrders = [
      PurchaseOrder(
        id: '1',
        poNumber: 'PO-2024-158',
        vendorName: 'Fresh Dairy Co.',
        amount: 4100,
        status: PurchaseOrderStatus.pending,
        date: DateTime.now(),
      ),
      PurchaseOrder(
        id: '2',
        poNumber: 'PO-2024-157',
        vendorName: 'Farm Fresh Meats',
        amount: 4200,
        status: PurchaseOrderStatus.ordered,
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
      PurchaseOrder(
        id: '3',
        poNumber: 'PO-2024-156',
        vendorName: 'Fresh Dairy Co.',
        amount: 1600,
        status: PurchaseOrderStatus.received,
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];

    const mockAnalytics = InventoryAnalytics(
      totalConsumption: 52450,
      totalCost: 115000,
      totalWastage: 11700,
      efficiencyScore: 0.942,
      consumptionTrend: [
        ChartDataPoint('Jan', 43000),
        ChartDataPoint('Feb', 49000),
        ChartDataPoint('Mar', 30000),
        ChartDataPoint('Apr', 25000),
        ChartDataPoint('May', 17000),
        ChartDataPoint('Jun', 22000),
      ],
    );

    emit(
      state.copyWith(
        isLoading: false,
        items: mockItems,
        recentOrders: mockOrders,
        analytics: mockAnalytics,
      ),
    );
  }

  void _onRefreshInventory(
    RefreshInventory event,
    Emitter<InventoryState> emit,
  ) {
    add(LoadInventory());
  }

  void _onUpdateSearchQuery(
    UpdateSearchQuery event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.copyWith(searchQuery: event.query));
  }

  void _onToggleAnalytics(ToggleAnalytics event, Emitter<InventoryState> emit) {
    emit(state.copyWith(showAnalytics: !state.showAnalytics));
  }

  void _onUpdateCategoryFilter(
    UpdateCategoryFilter event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.copyWith(categoryFilter: event.category));
  }

  void _onUpdateStatusFilter(
    UpdateStatusFilter event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.copyWith(statusFilter: event.status));
  }

  void _onToggleCompactView(
    ToggleCompactView event,
    Emitter<InventoryState> emit,
  ) {
    emit(state.copyWith(isCompactView: !state.isCompactView));
  }
}
