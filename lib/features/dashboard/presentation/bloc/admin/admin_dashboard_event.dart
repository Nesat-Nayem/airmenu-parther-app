import 'package:equatable/equatable.dart';

abstract class AdminDashboardEvent extends Equatable {
  const AdminDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data with optional date range
class LoadAdminDashboardData extends AdminDashboardEvent {
  final String dateRange;
  final String? startDate;
  final String? endDate;

  const LoadAdminDashboardData({
    this.dateRange = 'today',
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [dateRange, startDate, endDate];
}

/// Refresh dashboard data (reload with current filters)
class RefreshAdminDashboardData extends AdminDashboardEvent {
  const RefreshAdminDashboardData();
}

/// Filter by date range
class FilterByDateRange extends AdminDashboardEvent {
  final String dateRange;
  final String? startDate;
  final String? endDate;

  const FilterByDateRange({
    required this.dateRange,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [dateRange, startDate, endDate];
}

/// Filter by category (for future use)
class FilterByCategory extends AdminDashboardEvent {
  final String category;

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Search dashboard
class SearchDashboard extends AdminDashboardEvent {
  final String query;

  const SearchDashboard(this.query);

  @override
  List<Object?> get props => [query];
}

/// Update chart view period
class UpdateAdminChartView extends AdminDashboardEvent {
  final String chartType; // 'orders' or 'kitchen'
  final String period; // 'today', 'week', 'month'

  const UpdateAdminChartView({required this.chartType, required this.period});

  @override
  List<Object?> get props => [chartType, period];
}
