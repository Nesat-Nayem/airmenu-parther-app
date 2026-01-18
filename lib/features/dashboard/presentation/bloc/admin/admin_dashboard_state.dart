import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/shared/dashboard_models.dart';

abstract class AdminDashboardState extends Equatable {
  const AdminDashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AdminDashboardInitial extends AdminDashboardState {
  const AdminDashboardInitial();
}

/// Loading state
class AdminDashboardLoading extends AdminDashboardState {
  const AdminDashboardLoading();
}

/// Loaded state with data and current filters
class AdminDashboardLoaded extends AdminDashboardState {
  final DashboardDataModel data;
  final String currentView;
  final String dateRange;
  final String? startDate;
  final String? endDate;
  final String? selectedCategory;
  final String searchQuery;
  final bool isRefreshing;

  const AdminDashboardLoaded({
    required this.data,
    this.currentView = 'today',
    this.dateRange = 'today',
    this.startDate,
    this.endDate,
    this.selectedCategory,
    this.searchQuery = '',
    this.isRefreshing = false,
  });

  // Copy with method for updating state
  AdminDashboardLoaded copyWith({
    DashboardDataModel? data,
    String? currentView,
    String? dateRange,
    String? startDate,
    String? endDate,
    String? selectedCategory,
    String? searchQuery,
    bool? isRefreshing,
  }) {
    return AdminDashboardLoaded(
      data: data ?? this.data,
      currentView: currentView ?? this.currentView,
      dateRange: dateRange ?? this.dateRange,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }

  @override
  List<Object?> get props => [
    data,
    currentView,
    dateRange,
    startDate,
    endDate,
    selectedCategory,
    searchQuery,
    isRefreshing,
  ];
}

/// Error state with detailed message and error type
class AdminDashboardError extends AdminDashboardState {
  final String message;
  final String errorType; // 'network', 'parse', 'timeout', 'unknown'
  final StackTrace? stackTrace;

  const AdminDashboardError({
    required this.message,
    this.errorType = 'unknown',
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, errorType, stackTrace];
}

/// Refreshing state (shows loading overlay on existing data)
class AdminDashboardRefreshing extends AdminDashboardState {
  final DashboardDataModel currentData;

  const AdminDashboardRefreshing(this.currentData);

  @override
  List<Object?> get props => [currentData];
}
