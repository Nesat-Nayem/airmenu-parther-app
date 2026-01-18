import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';

abstract class VendorDashboardState extends Equatable {
  const VendorDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class VendorDashboardInitial extends VendorDashboardState {
  const VendorDashboardInitial();
}

/// Loading state
class VendorDashboardLoading extends VendorDashboardState {
  const VendorDashboardLoading();
}

/// Loaded state with data and current filters
class VendorDashboardLoaded extends VendorDashboardState {
  final VendorDashboardDataModel data;
  final String currentView;
  final String dateRange;
  final String orderType;
  final String branch;
  final String? startDate;
  final String? endDate;
  final bool isRefreshing;
  final List<BranchModel> availableBranches;

  const VendorDashboardLoaded({
    required this.data,
    this.currentView = 'today',
    this.dateRange = 'today',
    this.orderType = 'All Types',
    this.branch = 'Main Branch',
    this.startDate,
    this.endDate,
    this.isRefreshing = false,
    this.availableBranches = const [],
  });

  // Copy with method for updating state
  VendorDashboardLoaded copyWith({
    VendorDashboardDataModel? data,
    String? currentView,
    String? dateRange,
    String? orderType,
    String? branch,
    String? startDate,
    String? endDate,
    bool? isRefreshing,
    List<BranchModel>? availableBranches,
  }) {
    return VendorDashboardLoaded(
      data: data ?? this.data,
      currentView: currentView ?? this.currentView,
      dateRange: dateRange ?? this.dateRange,
      orderType: orderType ?? this.orderType,
      branch: branch ?? this.branch,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      availableBranches: availableBranches ?? this.availableBranches,
    );
  }

  @override
  List<Object?> get props => [
    data,
    currentView,
    dateRange,
    orderType,
    branch,
    startDate,
    endDate,
    isRefreshing,
    availableBranches,
  ];
}

/// Error state with detailed message and error type
class VendorDashboardError extends VendorDashboardState {
  final String message;
  final String errorType; // 'network', 'parse', 'timeout', 'unknown'
  final StackTrace? stackTrace;

  const VendorDashboardError({
    required this.message,
    this.errorType = 'unknown',
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, errorType, stackTrace];
}

/// Refreshing state (shows loading overlay on existing data)
class VendorDashboardRefreshing extends VendorDashboardState {
  final VendorDashboardDataModel currentData;

  const VendorDashboardRefreshing(this.currentData);

  @override
  List<Object?> get props => [currentData];
}

/// Empty state (no data available)
class VendorDashboardEmpty extends VendorDashboardState {
  const VendorDashboardEmpty();
}
