import 'package:airmenuai_partner_app/features/onboarding_pipeline/data/models/kyc_stats.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/domain/repositories/i_kyc_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_event.dart';
import 'package:airmenuai_partner_app/features/onboarding_pipeline/presentation/bloc/onboarding_pipeline_state.dart';

/// BLoC for managing the onboarding pipeline state with status-wise pagination
class OnboardingPipelineBloc
    extends Bloc<OnboardingPipelineEvent, OnboardingPipelineState> {
  final IKycRepository _repository;
  static const int _pageSize = 10;

  // Current filter state
  String? _currentRestaurantType;
  DateTime? _currentStartDate;
  DateTime? _currentEndDate;

  OnboardingPipelineBloc(this._repository) : super(const PipelineInitial()) {
    on<LoadKycBoard>(_onLoadKycBoard);
    on<LoadMoreKycByStatus>(_onLoadMoreKycByStatus);
    on<RefreshKycByStatus>(_onRefreshKycByStatus);
    on<ReviewKyc>(_onReviewKyc);
    on<ApplyFilters>(_onApplyFilters);
    on<ClearFilters>(_onClearFilters);
    on<FetchAdminSigningUrl>(_onFetchAdminSigningUrl);
    on<SyncAdobeStatus>(_onSyncAdobeStatus);
  }

  /// Handle initial loading of KYC board (stats + first page of each status)
  Future<void> _onLoadKycBoard(
    LoadKycBoard event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    emit(const PipelineLoading());

    // Update filter state from event
    _currentRestaurantType = event.restaurantType;
    _currentStartDate = event.startDate;
    _currentEndDate = event.endDate;

    try {
      // Load stats and first page of each status in parallel
      final results = await Future.wait([
        _repository.getKycStats(),
        _repository.getKycByStatus(
          status: 'pending',
          page: 1,
          limit: _pageSize,
          restaurantType: _currentRestaurantType,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
        _repository.getKycByStatus(
          status: 'approved',
          page: 1,
          limit: _pageSize,
          restaurantType: _currentRestaurantType,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
        _repository.getKycByStatus(
          status: 'rejected',
          page: 1,
          limit: _pageSize,
          restaurantType: _currentRestaurantType,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
        ),
      ]);

      final stats = results[0] as KycStats;
      final pendingResult = results[1] as ({List submissions, bool hasMore, int totalItems});
      final approvedResult = results[2] as ({List submissions, bool hasMore, int totalItems});
      final rejectedResult = results[3] as ({List submissions, bool hasMore, int totalItems});

      emit(PipelineLoaded(
        stats: stats,
        pendingState: StatusPaginationState(
          items: pendingResult.submissions.cast(),
          currentPage: 1,
          hasMore: pendingResult.hasMore,
          totalItems: pendingResult.totalItems,
        ),
        approvedState: StatusPaginationState(
          items: approvedResult.submissions.cast(),
          currentPage: 1,
          hasMore: approvedResult.hasMore,
          totalItems: approvedResult.totalItems,
        ),
        rejectedState: StatusPaginationState(
          items: rejectedResult.submissions.cast(),
          currentPage: 1,
          hasMore: rejectedResult.hasMore,
          totalItems: rejectedResult.totalItems,
        ),
        filterState: KycFilterState(
          restaurantType: _currentRestaurantType,
          startDate: _currentStartDate,
          endDate: _currentEndDate,
          isApplied: _currentRestaurantType != null || _currentStartDate != null || _currentEndDate != null,
        ),
      ));
    } catch (e) {
      emit(PipelineError(message: 'Failed to load KYC data: $e'));
    }
  }

  /// Handle loading more items for a specific status
  Future<void> _onLoadMoreKycByStatus(
    LoadMoreKycByStatus event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    if (state is! PipelineLoaded) return;

    final currentState = state as PipelineLoaded;
    final statusState = currentState.getStateByStatus(event.status);

    // Don't load if already loading or no more items
    if (statusState.isLoadingMore || !statusState.hasMore) return;

    // Emit loading more state
    emit(_updateStatusState(
      currentState,
      event.status,
      statusState.copyWith(isLoadingMore: true),
    ));

    try {
      final nextPage = statusState.currentPage + 1;
      final result = await _repository.getKycByStatus(
        status: event.status,
        page: nextPage,
        limit: _pageSize,
        restaurantType: _currentRestaurantType,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      );

      final updatedState = state as PipelineLoaded;
      final updatedStatusState = updatedState.getStateByStatus(event.status);

      emit(_updateStatusState(
        updatedState,
        event.status,
        updatedStatusState.copyWith(
          items: [...updatedStatusState.items, ...result.submissions],
          currentPage: nextPage,
          hasMore: result.hasMore,
          isLoadingMore: false,
          totalItems: result.totalItems,
        ),
      ));
    } catch (e) {
      // Revert loading state on error
      if (state is PipelineLoaded) {
        final revertState = state as PipelineLoaded;
        emit(_updateStatusState(
          revertState,
          event.status,
          revertState.getStateByStatus(event.status).copyWith(isLoadingMore: false),
        ));
      }
    }
  }

  /// Handle refreshing a specific status column
  Future<void> _onRefreshKycByStatus(
    RefreshKycByStatus event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    if (state is! PipelineLoaded) return;

    final currentState = state as PipelineLoaded;
    final statusState = currentState.getStateByStatus(event.status);

    // Set loading state
    emit(_updateStatusState(
      currentState,
      event.status,
      statusState.copyWith(isLoading: true),
    ));

    try {
      // Refresh stats and the specific status
      final results = await Future.wait([
        _repository.getKycStats(),
        _repository.getKycByStatus(status: event.status, page: 1, limit: _pageSize),
      ]);

      final stats = results[0] as KycStats;
      final result = results[1] as ({List submissions, bool hasMore, int totalItems});

      if (state is PipelineLoaded) {
        final updatedState = (state as PipelineLoaded).copyWith(stats: stats);
        emit(_updateStatusState(
          updatedState,
          event.status,
          StatusPaginationState(
            items: result.submissions.cast(),
            currentPage: 1,
            hasMore: result.hasMore,
            totalItems: result.totalItems,
          ),
        ));
      }
    } catch (e) {
      // Revert loading state on error
      if (state is PipelineLoaded) {
        final revertState = state as PipelineLoaded;
        emit(_updateStatusState(
          revertState,
          event.status,
          revertState.getStateByStatus(event.status).copyWith(isLoading: false),
        ));
      }
    }
  }

  /// Handle reviewing (approve/reject) a KYC submission
  Future<void> _onReviewKyc(
    ReviewKyc event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    try {
      await _repository.reviewKyc(
        event.id,
        event.status,
        comments: event.comments,
      );
      // Reload all data after review with current filters
      add(LoadKycBoard(
        restaurantType: _currentRestaurantType,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      ));
    } catch (e) {
      emit(PipelineError(message: 'Failed to update KYC status: $e'));
    }
  }

  /// Handle applying filters
  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    // Show filtering state if we have loaded data
    if (state is PipelineLoaded) {
      emit((state as PipelineLoaded).copyWith(isFiltering: true));
    }

    // Reload with new filters
    add(LoadKycBoard(
      restaurantType: event.restaurantType,
      startDate: event.startDate,
      endDate: event.endDate,
    ));
  }

  /// Handle clearing filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    _currentRestaurantType = null;
    _currentStartDate = null;
    _currentEndDate = null;

    // Reload without filters
    add(const LoadKycBoard());
  }

  /// Handle fetching admin Adobe signing URL
  Future<void> _onFetchAdminSigningUrl(
    FetchAdminSigningUrl event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    emit(const AdminSigningUrlLoading());
    try {
      final url = await _repository.getAdminSigningUrl(event.kycId);
      if (url.isNotEmpty) {
        emit(AdminSigningUrlLoaded(signingUrl: url, kycId: event.kycId));
      } else {
        emit(const AdminSigningUrlError(
          message: 'Admin signing URL not available. Vendor may need to sign first.',
        ));
      }
    } catch (e) {
      emit(AdminSigningUrlError(message: 'Failed to get signing URL: $e'));
    }
  }

  /// Handle syncing Adobe agreement status
  Future<void> _onSyncAdobeStatus(
    SyncAdobeStatus event,
    Emitter<OnboardingPipelineState> emit,
  ) async {
    try {
      print('[Flutter BLoC] SyncAdobeStatus: Starting sync for kycId=${event.kycId}');
      final data = await _repository.syncAdobeStatus(event.kycId);
      print('[Flutter BLoC] SyncAdobeStatus: Success! data=$data');
      emit(AdobeStatusSynced(data: data));
      // Reload the board to reflect updated status
      add(LoadKycBoard(
        restaurantType: _currentRestaurantType,
        startDate: _currentStartDate,
        endDate: _currentEndDate,
      ));
    } catch (e) {
      print('[Flutter BLoC] SyncAdobeStatus: ERROR: $e');
      emit(PipelineError(message: 'Failed to sync Adobe status: $e'));
    }
  }

  /// Helper to update a specific status state in PipelineLoaded
  PipelineLoaded _updateStatusState(
    PipelineLoaded current,
    String status,
    StatusPaginationState newState,
  ) {
    switch (status.toLowerCase()) {
      case 'pending':
        return current.copyWith(pendingState: newState);
      case 'approved':
        return current.copyWith(approvedState: newState);
      case 'rejected':
        return current.copyWith(rejectedState: newState);
      default:
        return current;
    }
  }
}
