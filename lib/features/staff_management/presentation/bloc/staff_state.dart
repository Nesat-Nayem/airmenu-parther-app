import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/staff_management/data/models/staff_model.dart';

/// Stats for the top tiles
class StaffStats extends Equatable {
  final int totalStaff;
  final int activeNow;
  final int rolesCount;
  final int disabled;

  const StaffStats({
    this.totalStaff = 0,
    this.activeNow = 0,
    this.rolesCount = 0,
    this.disabled = 0,
  });

  factory StaffStats.fromStaffList(List<StaffModel> staff) {
    final totalStaff = staff.length;
    final activeNow = staff.where((s) => s.isActive).length;
    final disabled = staff.where((s) => !s.isActive).length;

    // Count unique roles
    final uniqueRoles = staff
        .map((s) => s.staffRole)
        .where((r) => r != null && r != '-')
        .toSet();
    final rolesCount = uniqueRoles.isEmpty ? totalStaff : uniqueRoles.length;

    return StaffStats(
      totalStaff: totalStaff,
      activeNow: activeNow,
      rolesCount: rolesCount,
      disabled: disabled,
    );
  }

  @override
  List<Object?> get props => [totalStaff, activeNow, rolesCount, disabled];
}

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class StaffInitial extends StaffState {
  const StaffInitial();
}

/// Loading state
class StaffLoading extends StaffState {
  const StaffLoading();
}

/// Successfully loaded
class StaffLoaded extends StaffState {
  final List<StaffModel> allStaff;
  final List<StaffModel> filteredStaff;
  final StaffStats stats;
  final String searchQuery;
  final String? selectedRole;
  final bool isRefreshing;
  final Set<String> loadingIds; // IDs currently being updated

  const StaffLoaded({
    required this.allStaff,
    required this.filteredStaff,
    required this.stats,
    this.searchQuery = '',
    this.selectedRole,
    this.isRefreshing = false,
    this.loadingIds = const {},
  });

  StaffLoaded copyWith({
    List<StaffModel>? allStaff,
    List<StaffModel>? filteredStaff,
    StaffStats? stats,
    String? searchQuery,
    String? selectedRole,
    bool? isRefreshing,
    Set<String>? loadingIds,
  }) {
    return StaffLoaded(
      allStaff: allStaff ?? this.allStaff,
      filteredStaff: filteredStaff ?? this.filteredStaff,
      stats: stats ?? this.stats,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRole: selectedRole,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      loadingIds: loadingIds ?? this.loadingIds,
    );
  }

  @override
  List<Object?> get props => [
    allStaff,
    filteredStaff,
    stats,
    searchQuery,
    selectedRole,
    isRefreshing,
    loadingIds,
  ];
}

/// Error state
class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Action success states
class StaffActionSuccess extends StaffState {
  final String message;

  const StaffActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class StaffActionFailure extends StaffState {
  final String message;

  const StaffActionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
