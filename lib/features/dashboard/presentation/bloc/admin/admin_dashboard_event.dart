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

/// Filter by category (restaurant/qsr/all)
class FilterByCategory extends AdminDashboardEvent {
  final String category; // 'all', 'restaurant', 'qsr'

  const FilterByCategory(this.category);

  @override
  List<Object?> get props => [category];
}

/// Search dashboard — triggers restaurant autocomplete + data reload
class SearchDashboard extends AdminDashboardEvent {
  final String query;

  const SearchDashboard(this.query);

  @override
  List<Object?> get props => [query];
}

/// Select a specific restaurant from autocomplete
class SelectRestaurantFilter extends AdminDashboardEvent {
  final String? restaurantName; // null = clear filter

  const SelectRestaurantFilter(this.restaurantName);

  @override
  List<Object?> get props => [restaurantName];
}

/// Update chart view period
class UpdateAdminChartView extends AdminDashboardEvent {
  final String chartType; // 'orders' or 'kitchen'
  final String period; // 'today', 'week', 'month'

  const UpdateAdminChartView({required this.chartType, required this.period});

  @override
  List<Object?> get props => [chartType, period];
}
