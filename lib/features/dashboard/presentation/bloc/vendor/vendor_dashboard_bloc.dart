import 'package:airmenuai_partner_app/utils/logger/Log.dart';
import 'package:bloc/bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/repositories/vendor_dashboard_repository.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'vendor_dashboard_event.dart';
import 'vendor_dashboard_state.dart';

class VendorDashboardBloc
    extends Bloc<VendorDashboardEvent, VendorDashboardState> {
  final VendorDashboardRepository repository;

  VendorDashboardBloc({required this.repository})
    : super(const VendorDashboardInitial()) {
    on<LoadVendorDashboardData>(_onLoadDashboardData);
    on<RefreshVendorDashboardData>(_onRefreshDashboardData);
    on<UpdateVendorChartView>(_onUpdateChartView);
    on<UpdateDashboardFilters>(_onUpdateFilters);
  }

  Future<void> _onLoadDashboardData(
    LoadVendorDashboardData event,
    Emitter<VendorDashboardState> emit,
  ) async {
    emit(const VendorDashboardLoading());

    try {
      final data = await repository.getDashboardData(
        dateRange: event.dateRange,
        startDate: event.startDate,
        endDate: event.endDate,
      );

      final branches = await repository.getBranches();

      // Check if data is empty
      if (_isDataEmpty(data)) {
        emit(const VendorDashboardEmpty());
        return;
      }

      emit(
        VendorDashboardLoaded(
          data: data,
          dateRange: event.dateRange,
          startDate: event.startDate,
          endDate: event.endDate,
          availableBranches: branches,
        ),
      );
    } catch (error, stackTrace) {
      print('Here is my error for hotel list $error $stackTrace');
      emit(
        VendorDashboardError(
          message: _getErrorMessage(error),
          errorType: _getErrorType(error),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onRefreshDashboardData(
    RefreshVendorDashboardData event,
    Emitter<VendorDashboardState> emit,
  ) async {
    final currentState = state;
    String period = 'today';
    String? orderType;
    String? branch;

    if (currentState is VendorDashboardLoaded) {
      period = currentState.dateRange;
      orderType = currentState.orderType;
      branch = currentState.branch;
      emit(VendorDashboardRefreshing(currentState.data));
    } else {
      emit(const VendorDashboardLoading());
    }

    try {
      final data = await repository.getDashboardData(
        dateRange: period,
        orderType: orderType,
        branch: branch,
      );

      if (_isDataEmpty(data)) {
        emit(const VendorDashboardEmpty());
        return;
      }

      if (currentState is VendorDashboardLoaded) {
        emit(currentState.copyWith(data: data));
      } else {
        emit(VendorDashboardLoaded(data: data));
      }
    } catch (error, stackTrace) {
      emit(
        VendorDashboardError(
          message: _getErrorMessage(error),
          errorType: _getErrorType(error),
          stackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> _onUpdateFilters(
    UpdateDashboardFilters event,
    Emitter<VendorDashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorDashboardLoaded) return;

    final newPeriod = event.period ?? currentState.dateRange;
    final newOrderType = event.orderType ?? currentState.orderType;
    final newBranch = event.branch ?? currentState.branch;

    // Optimistically update UI filters
    emit(
      currentState.copyWith(
        dateRange: newPeriod,
        orderType: newOrderType,
        branch: newBranch,
        isRefreshing: true, // Show loading indicator
      ),
    );

    try {
      final data = await repository.getDashboardData(
        dateRange: newPeriod,
        orderType: newOrderType,
        branch: newBranch,
      );

      emit(
        currentState.copyWith(
          data: data,
          dateRange: newPeriod,
          orderType: newOrderType,
          branch: newBranch,
          isRefreshing: false,
        ),
      );
    } catch (error) {
      Log.error('Error updating filters: $error');
      emit(currentState.copyWith(isRefreshing: false));
    }
  }

  Future<void> _onUpdateChartView(
    UpdateVendorChartView event,
    Emitter<VendorDashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! VendorDashboardLoaded) return;

    try {
      final ordersOverTime = await repository.getOrdersOverTimeData(
        event.period,
      );
      final updatedData = currentState.data.copyWith(
        ordersOverTime: ordersOverTime,
      );
      emit(currentState.copyWith(data: updatedData, currentView: event.period));
    } catch (error) {
      Log.error('Error updating chart view: $error  ');
    }
  }

  /// Check if dashboard data is empty
  bool _isDataEmpty(VendorDashboardDataModel data) {
    // Return false to always show dashboard, even with 0 data
    return false;
  }

  /// Get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timed out. Please try again.';
    } else if (error.toString().contains('FormatException')) {
      return 'Invalid data format received.';
    } else {
      return 'Failed to load dashboard data. Please try again.';
    }
  }

  /// Determine error type for better error handling
  String _getErrorType(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'network';
    } else if (error.toString().contains('TimeoutException')) {
      return 'timeout';
    } else if (error.toString().contains('FormatException')) {
      return 'parse';
    } else {
      return 'unknown';
    }
  }
}
