import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_submission.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_stats.dart';

/// Pagination state for each status column
class StatusPaginationState extends Equatable {
  final List<KycSubmission> items;
  final int currentPage;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final int totalItems;

  const StatusPaginationState({
    this.items = const [],
    this.currentPage = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.totalItems = 0,
  });

  StatusPaginationState copyWith({
    List<KycSubmission>? items,
    int? currentPage,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    int? totalItems,
  }) {
    return StatusPaginationState(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  @override
  List<Object?> get props => [items, currentPage, hasMore, isLoading, isLoadingMore, totalItems];
}

/// Base class for all onboarding pipeline states
abstract class OnboardingPipelineState extends Equatable {
  const OnboardingPipelineState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class PipelineInitial extends OnboardingPipelineState {
  const PipelineInitial();
}

/// Loading state while fetching initial data (shows full skeleton)
class PipelineLoading extends OnboardingPipelineState {
  const PipelineLoading();
}

/// Filter state for the pipeline
class KycFilterState extends Equatable {
  final String? restaurantType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isApplied;

  const KycFilterState({
    this.restaurantType,
    this.startDate,
    this.endDate,
    this.isApplied = false,
  });

  KycFilterState copyWith({
    String? restaurantType,
    DateTime? startDate,
    DateTime? endDate,
    bool? isApplied,
  }) {
    return KycFilterState(
      restaurantType: restaurantType ?? this.restaurantType,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isApplied: isApplied ?? this.isApplied,
    );
  }

  KycFilterState clear() {
    return const KycFilterState();
  }

  bool get hasFilters => restaurantType != null || startDate != null || endDate != null;

  @override
  List<Object?> get props => [restaurantType, startDate, endDate, isApplied];
}

/// Loaded state with pipeline data and pagination per status
class PipelineLoaded extends OnboardingPipelineState {
  final KycStats stats;
  final StatusPaginationState pendingState;
  final StatusPaginationState approvedState;
  final StatusPaginationState rejectedState;
  final KycFilterState filterState;
  final bool isFiltering;

  const PipelineLoaded({
    required this.stats,
    required this.pendingState,
    required this.approvedState,
    required this.rejectedState,
    this.filterState = const KycFilterState(),
    this.isFiltering = false,
  });

  /// Helper to get state by status string
  StatusPaginationState getStateByStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return pendingState;
      case 'approved':
        return approvedState;
      case 'rejected':
        return rejectedState;
      default:
        return pendingState;
    }
  }

  PipelineLoaded copyWith({
    KycStats? stats,
    StatusPaginationState? pendingState,
    StatusPaginationState? approvedState,
    StatusPaginationState? rejectedState,
    KycFilterState? filterState,
    bool? isFiltering,
  }) {
    return PipelineLoaded(
      stats: stats ?? this.stats,
      pendingState: pendingState ?? this.pendingState,
      approvedState: approvedState ?? this.approvedState,
      rejectedState: rejectedState ?? this.rejectedState,
      filterState: filterState ?? this.filterState,
      isFiltering: isFiltering ?? this.isFiltering,
    );
  }

  @override
  List<Object?> get props => [stats, pendingState, approvedState, rejectedState, filterState, isFiltering];
}

/// Error state when data loading fails
class PipelineError extends OnboardingPipelineState {
  final String message;

  const PipelineError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State for admin Adobe signing URL
class AdminSigningUrlLoading extends OnboardingPipelineState {
  const AdminSigningUrlLoading();
}

class AdminSigningUrlLoaded extends OnboardingPipelineState {
  final String signingUrl;
  final String kycId;

  const AdminSigningUrlLoaded({required this.signingUrl, required this.kycId});

  @override
  List<Object?> get props => [signingUrl, kycId];
}

class AdminSigningUrlError extends OnboardingPipelineState {
  final String message;

  const AdminSigningUrlError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// State for Adobe status sync
class AdobeStatusSynced extends OnboardingPipelineState {
  final Map<String, dynamic> data;

  const AdobeStatusSynced({required this.data});

  @override
  List<Object?> get props => [data];
}
