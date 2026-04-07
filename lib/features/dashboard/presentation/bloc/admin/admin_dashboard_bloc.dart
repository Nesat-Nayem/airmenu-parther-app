import 'package:bloc/bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';
import 'admin_dashboard_event.dart';
import 'admin_dashboard_state.dart';

class AdminDashboardBloc
    extends Bloc<AdminDashboardEvent, AdminDashboardState> {
  final AdminDashboardRepository repository;

  AdminDashboardBloc({required this.repository})
      : super(const AdminDashboardInitial()) {
    on<LoadAdminDashboardData>(_onLoadDashboardData);
    on<RefreshAdminDashboardData>(_onRefreshDashboardData);
    on<FilterByDateRange>(_onFilterByDateRange);
    on<FilterByCategory>(_onFilterByCategory);
    on<SearchDashboard>(_onSearchDashboard);
    on<SelectRestaurantFilter>(_onSelectRestaurantFilter);
    on<UpdateAdminChartView>(_onUpdateChartView);
  }

  /// Fetch all dashboard data with current filters
  Future<DashboardDataModel> _fetchAll({
    required String dateRange,
    String? startDate,
    String? endDate,
    String? restaurantType,
    String? search,
  }) async {
    final period = dateRange == 'today'
        ? 'today'
        : (dateRange == '7days' ? 'week' : 'month');

    final dashboardData = await repository.getDashboardData(
      dateRange: dateRange,
      startDate: startDate,
      endDate: endDate,
      restaurantType: restaurantType,
      search: search,
    );

    final results = await Future.wait([
      repository.getOrdersByType(period: period),
      repository.getKitchenLoad(period: period),
      repository.getRestaurantPerformance(),
      repository.getRiderSLA(),
      repository.getAlerts(),
      repository.getTopRestaurants(
          restaurantType: restaurantType, search: search, dateRange: dateRange),
      repository.getActivities(),
    ]);

    return DashboardDataModel(
      stats: dashboardData.stats,
      alerts: results[4] as List<HighRiskAlertModel>,
      liveActivities: results[6] as List<LiveActivityModel>,
      topRestaurants: results[5] as List<TopRestaurantModel>,
      ordersByType: results[0] as OrdersByTypeChartModel,
      kitchenLoad: results[1] as KitchenLoadChartModel,
      restaurantPerformance: results[2] as List<RestaurantPerformanceModel>,
      riderSLA: results[3] as List<RiderSLAModel>,
    );
  }

  Future<void> _onLoadDashboardData(
    LoadAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());
    try {
      final fullData = await _fetchAll(
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(AdminDashboardLoaded(
        data: fullData,
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
      ));
    } catch (e, s) {
      emit(AdminDashboardError(
          message: 'Failed to load dashboard: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: s));
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;
    final cur = state as AdminDashboardLoaded;
    emit(AdminDashboardRefreshing(cur.data));
    try {
      final fullData = await _fetchAll(
        dateRange: cur.dateRange,
        startDate: cur.startDate,
        endDate: cur.endDate,
        restaurantType: cur.selectedCategory,
        search: cur.selectedRestaurant,
      );
      emit(cur.copyWith(data: fullData, isRefreshing: false));
    } catch (e) {
      emit(AdminDashboardError(
          message: 'Failed to refresh: ${e.toString()}',
          errorType: _getErrorType(e)));
    }
  }

  Future<void> _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<AdminDashboardState> emit,
  ) async {
    final cur =
        state is AdminDashboardLoaded ? state as AdminDashboardLoaded : null;
    emit(const AdminDashboardLoading());
    try {
      final fullData = await _fetchAll(
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
        restaurantType: cur?.selectedCategory,
        search: cur?.selectedRestaurant,
      );
      emit(AdminDashboardLoaded(
        data: fullData,
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
        selectedCategory: cur?.selectedCategory,
        selectedRestaurant: cur?.selectedRestaurant,
        searchQuery: cur?.searchQuery ?? '',
      ));
    } catch (e, s) {
      emit(AdminDashboardError(
          message: 'Failed to filter: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: s));
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;
    final cur = state as AdminDashboardLoaded;
    emit(const AdminDashboardLoading());
    try {
      final fullData = await _fetchAll(
        dateRange: cur.dateRange,
        startDate: cur.startDate,
        endDate: cur.endDate,
        restaurantType: event.category == 'all' ? null : event.category,
        search: cur.selectedRestaurant,
      );
      emit(cur.copyWith(
        data: fullData,
        selectedCategory: event.category,
        searchSuggestions: [],
      ));
    } catch (e, s) {
      emit(AdminDashboardError(
          message: 'Failed to filter: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: s));
    }
  }

  Future<void> _onSearchDashboard(
    SearchDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;
    final cur = state as AdminDashboardLoaded;

    if (event.query.isEmpty) {
      emit(cur.copyWith(
          searchQuery: '', searchSuggestions: [], clearRestaurant: true));
      try {
        final fullData = await _fetchAll(
          dateRange: cur.dateRange,
          restaurantType: cur.selectedCategory,
        );
        emit(cur.copyWith(
            data: fullData,
            searchQuery: '',
            searchSuggestions: [],
            clearRestaurant: true));
      } catch (_) {}
      return;
    }

    emit(cur.copyWith(searchQuery: event.query));
    try {
      final suggestions = await repository.searchRestaurants(
        query: event.query,
        restaurantType:
            cur.selectedCategory == 'all' ? null : cur.selectedCategory,
      );
      emit(cur.copyWith(
          searchQuery: event.query, searchSuggestions: suggestions));
    } catch (_) {}
  }

  Future<void> _onSelectRestaurantFilter(
    SelectRestaurantFilter event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;
    final cur = state as AdminDashboardLoaded;
    emit(const AdminDashboardLoading());
    try {
      final fullData = await _fetchAll(
        dateRange: cur.dateRange,
        startDate: cur.startDate,
        endDate: cur.endDate,
        restaurantType: cur.selectedCategory,
        search: event.restaurantName,
      );
      emit(cur.copyWith(
        data: fullData,
        selectedRestaurant: event.restaurantName,
        searchQuery: event.restaurantName ?? '',
        searchSuggestions: [],
        clearRestaurant: event.restaurantName == null,
      ));
    } catch (e, s) {
      emit(AdminDashboardError(
          message: 'Failed to filter: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: s));
    }
  }

  Future<void> _onUpdateChartView(
    UpdateAdminChartView event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;
    final cur = state as AdminDashboardLoaded;
    try {
      final results = await Future.wait([
        repository.getOrdersByType(period: event.period),
        repository.getKitchenLoad(period: event.period),
      ]);
      emit(cur.copyWith(
        data: cur.data.copyWith(
          ordersByType: results[0] as OrdersByTypeChartModel,
          kitchenLoad: results[1] as KitchenLoadChartModel,
        ),
        currentView: event.period,
      ));
    } catch (_) {}
  }

  String _getErrorType(dynamic error) {
    final s = error.toString().toLowerCase();
    if (s.contains('timeout')) return 'timeout';
    if (s.contains('network') || s.contains('socket')) return 'network';
    if (s.contains('parse') || s.contains('json')) return 'parse';
    return 'unknown';
  }
}
