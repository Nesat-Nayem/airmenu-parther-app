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
    on<UpdateAdminChartView>(_onUpdateChartView);
  }

  Future<void> _onLoadDashboardData(
    LoadAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    try {
      // Fetch main dashboard data
      final dashboardData = await repository.getDashboardData(
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      // Fetch additional data in parallel
      final results = await Future.wait([
        repository.getOrdersByType(period: 'today'),
        repository.getKitchenLoad(period: 'today'),
        repository.getRestaurantPerformance(),
        repository.getRiderSLA(),
        repository.getAlerts(), // Fetch alerts from dedicated endpoint
        repository
            .getTopRestaurants(), // Fetch top restaurants from dedicated endpoint
        repository.getActivities(), // Fetch activities from dedicated endpoint
      ]);

      final ordersByType = results[0] as OrdersByTypeChartModel;
      final kitchenLoad = results[1] as KitchenLoadChartModel;
      final restaurantPerformance =
          results[2] as List<RestaurantPerformanceModel>;
      final riderSLA = results[3] as List<RiderSLAModel>;
      final alerts = results[4] as List<HighRiskAlertModel>;
      final topRestaurants = results[5] as List<TopRestaurantModel>;
      final liveActivities = results[6] as List<LiveActivityModel>;

      final fullData = DashboardDataModel(
        stats: dashboardData.stats,
        alerts: alerts, // Use alerts from dedicated API
        liveActivities: liveActivities, // Use activities from dedicated API
        topRestaurants:
            topRestaurants, // Use top restaurants from dedicated API
        ordersByType: ordersByType,
        kitchenLoad: kitchenLoad,
        restaurantPerformance: restaurantPerformance,
        riderSLA: riderSLA,
      );

      emit(
        AdminDashboardLoaded(
          data: fullData,
          dateRange: event.dateRange,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e, stackTrace) {
      emit(
        AdminDashboardError(
          message: 'Failed to load dashboard data: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshAdminDashboardData event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;

    final currentState = state as AdminDashboardLoaded;
    emit(currentState.copyWith(isRefreshing: true));

    try {
      // Reload with current filters
      final dashboardData = await repository.getDashboardData(
        dateRange: currentState.dateRange,
        startDate: currentState.startDate,
        endDate: currentState.endDate,
      );

      final results = await Future.wait([
        repository.getOrdersByType(period: 'today'),
        repository.getKitchenLoad(period: 'today'),
        repository.getRestaurantPerformance(),
        repository.getRiderSLA(),
        repository.getAlerts(), // Fetch alerts from dedicated endpoint
        repository
            .getTopRestaurants(), // Fetch top restaurants from dedicated endpoint
        repository.getActivities(), // Fetch activities from dedicated endpoint
      ]);

      final fullData = DashboardDataModel(
        stats: dashboardData.stats,
        alerts:
            results[4]
                as List<HighRiskAlertModel>, // Use alerts from dedicated API
        liveActivities:
            results[6]
                as List<LiveActivityModel>, // Use activities from dedicated API
        topRestaurants:
            results[5]
                as List<
                  TopRestaurantModel
                >, // Use top restaurants from dedicated API
        ordersByType: results[0] as OrdersByTypeChartModel,
        kitchenLoad: results[1] as KitchenLoadChartModel,
        restaurantPerformance: results[2] as List<RestaurantPerformanceModel>,
        riderSLA: results[3] as List<RiderSLAModel>,
      );

      emit(currentState.copyWith(data: fullData, isRefreshing: false));
    } catch (e) {
      emit(
        AdminDashboardError(
          message: 'Failed to refresh dashboard: ${e.toString()}',
          errorType: _getErrorType(e),
        ),
      );
    }
  }

  Future<void> _onFilterByDateRange(
    FilterByDateRange event,
    Emitter<AdminDashboardState> emit,
  ) async {
    emit(const AdminDashboardLoading());

    try {
      final dashboardData = await repository.getDashboardData(
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final results = await Future.wait([
        repository.getOrdersByType(
          period: event.dateRange == 'today'
              ? 'today'
              : event.dateRange == '30days'
              ? 'month'
              : 'today',
        ),
        repository.getKitchenLoad(
          period: event.dateRange == 'today'
              ? 'today'
              : event.dateRange == '30days'
              ? 'month'
              : 'today',
        ),
        repository.getRestaurantPerformance(),
        repository.getRiderSLA(),
        repository.getAlerts(), // Fetch alerts from dedicated endpoint
        repository
            .getTopRestaurants(), // Fetch top restaurants from dedicated endpoint
        repository.getActivities(), // Fetch activities from dedicated endpoint
      ]);

      final fullData = DashboardDataModel(
        stats: dashboardData.stats,
        alerts:
            results[4]
                as List<HighRiskAlertModel>, // Use alerts from dedicated API
        liveActivities:
            results[6]
                as List<LiveActivityModel>, // Use activities from dedicated API
        topRestaurants:
            results[5]
                as List<
                  TopRestaurantModel
                >, // Use top restaurants from dedicated API
        ordersByType: results[0] as OrdersByTypeChartModel,
        kitchenLoad: results[1] as KitchenLoadChartModel,
        restaurantPerformance: results[2] as List<RestaurantPerformanceModel>,
        riderSLA: results[3] as List<RiderSLAModel>,
      );

      emit(
        AdminDashboardLoaded(
          data: fullData,
          dateRange: event.dateRange,
          startDate: event.startDate,
          endDate: event.endDate,
        ),
      );
    } catch (e, stackTrace) {
      emit(
        AdminDashboardError(
          message: 'Failed to filter dashboard: ${e.toString()}',
          errorType: _getErrorType(e),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onFilterByCategory(
    FilterByCategory event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;

    final currentState = state as AdminDashboardLoaded;
    emit(currentState.copyWith(selectedCategory: event.category));
  }

  Future<void> _onSearchDashboard(
    SearchDashboard event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;

    final currentState = state as AdminDashboardLoaded;
    emit(currentState.copyWith(searchQuery: event.query));
  }

  Future<void> _onUpdateChartView(
    UpdateAdminChartView event,
    Emitter<AdminDashboardState> emit,
  ) async {
    if (state is! AdminDashboardLoaded) return;

    final currentState = state as AdminDashboardLoaded;

    try {
      // Fetch updated chart data based on the selected period
      final results = await Future.wait([
        repository.getOrdersByType(period: event.period),
        repository.getKitchenLoad(period: event.period),
      ]);

      final ordersByType = results[0] as OrdersByTypeChartModel;
      final kitchenLoad = results[1] as KitchenLoadChartModel;

      // Update the data with new chart data
      final updatedData = currentState.data.copyWith(
        ordersByType: ordersByType,
        kitchenLoad: kitchenLoad,
      );

      emit(currentState.copyWith(data: updatedData, currentView: event.period));
    } catch (e) {
      // If error, just keep current state
      // Could emit error state but for charts it's better to keep showing old data
    }
  }

  String _getErrorType(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('timeout')) return 'timeout';
    if (errorString.contains('network') || errorString.contains('socket')) {
      return 'network';
    }
    if (errorString.contains('parse') || errorString.contains('json')) {
      return 'parse';
    }
    return 'unknown';
  }
}
