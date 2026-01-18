import 'package:equatable/equatable.dart';

abstract class VendorDashboardEvent extends Equatable {
  const VendorDashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard data with optional date range
class LoadVendorDashboardData extends VendorDashboardEvent {
  final String dateRange;
  final String? startDate;
  final String? endDate;

  const LoadVendorDashboardData({
    this.dateRange = 'today',
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [dateRange, startDate, endDate];
}

/// Refresh dashboard data (reload with current filters)
class RefreshVendorDashboardData extends VendorDashboardEvent {
  const RefreshVendorDashboardData();
}

/// Update chart view period
class UpdateVendorChartView extends VendorDashboardEvent {
  final String period; // 'today', 'week', 'month'

  const UpdateVendorChartView({required this.period});

  @override
  List<Object?> get props => [period];
}

/// Update dashboard filters
class UpdateDashboardFilters extends VendorDashboardEvent {
  final String? period;
  final String? orderType;
  final String? branch;

  const UpdateDashboardFilters({this.period, this.orderType, this.branch});

  @override
  List<Object?> get props => [period, orderType, branch];
}
