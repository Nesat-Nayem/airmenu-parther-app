import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_state.dart';

/// BLoC for Marketing feature
/// Handles all marketing data operations with proper error handling
class MarketingBloc extends Bloc<MarketingEvent, MarketingState> {
  final IMarketingRepository _repository;

  MarketingBloc(this._repository) : super(MarketingState.initial()) {
    on<LoadMarketingData>(_onLoadMarketingData);
    on<SwitchMarketingTab>(_onSwitchTab);
    on<SearchCampaigns>(_onSearchCampaigns);
    on<SearchPromoCodes>(_onSearchPromoCodes);
    on<TogglePromoCodeStatus>(_onTogglePromoCodeStatus);
    on<RefreshMarketingData>(_onRefreshMarketingData);
    on<ClearSearch>(_onClearSearch);
    on<RetryMarketingLoad>(_onRetryLoad);
  }

  /// Load all marketing data in parallel
  Future<void> _onLoadMarketingData(
    LoadMarketingData event,
    Emitter<MarketingState> emit,
  ) async {
    emit(
      state.copyWith(
        statsStatus: MarketingLoadStatus.loading,
        campaignsStatus: MarketingLoadStatus.loading,
        promoCodesStatus: MarketingLoadStatus.loading,
        summaryStatus: MarketingLoadStatus.loading,
        clearError: true,
      ),
    );

    // Load all data in parallel for better performance
    final results = await Future.wait([
      _repository.getMarketingStats(),
      _repository.getCampaigns(),
      _repository.getPromoCodes(),
      _repository.getMarketingSummary(),
    ]);

    // Process stats result
    final statsResult = results[0] as MarketingResult<MarketingStatsModel>;
    statsResult.when(
      success: (data) {
        emit(
          state.copyWith(stats: data, statsStatus: MarketingLoadStatus.success),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            statsStatus: MarketingLoadStatus.failure,
            error: error,
          ),
        );
      },
    );

    // Process campaigns result
    final campaignsResult = results[1] as MarketingResult<List<CampaignModel>>;
    campaignsResult.when(
      success: (data) {
        emit(
          state.copyWith(
            campaigns: data,
            filteredCampaigns: data,
            campaignsStatus: data.isEmpty
                ? MarketingLoadStatus.empty
                : MarketingLoadStatus.success,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            campaignsStatus: MarketingLoadStatus.failure,
            error: error,
          ),
        );
      },
    );

    // Process promo codes result
    final promoCodesResult =
        results[2] as MarketingResult<List<PromoCodeModel>>;
    promoCodesResult.when(
      success: (data) {
        emit(
          state.copyWith(
            promoCodes: data,
            filteredPromoCodes: data,
            promoCodesStatus: data.isEmpty
                ? MarketingLoadStatus.empty
                : MarketingLoadStatus.success,
          ),
        );
      },
      failure: (error) {
        emit(
          state.copyWith(
            promoCodesStatus: MarketingLoadStatus.failure,
            error: error,
          ),
        );
      },
    );

    // Process summary result
    final summaryResult = results[3] as MarketingResult<MarketingSummaryModel>;
    summaryResult.when(
      success: (data) {
        emit(
          state.copyWith(
            summary: data,
            summaryStatus: MarketingLoadStatus.success,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(summaryStatus: MarketingLoadStatus.failure));
      },
    );
  }

  /// Switch between tabs
  void _onSwitchTab(SwitchMarketingTab event, Emitter<MarketingState> emit) {
    emit(state.copyWith(currentTab: event.tab));
  }

  /// Search campaigns
  Future<void> _onSearchCampaigns(
    SearchCampaigns event,
    Emitter<MarketingState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(campaignSearchQuery: query));

    if (query.isEmpty) {
      emit(state.copyWith(filteredCampaigns: state.campaigns));
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.campaigns
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();

    emit(state.copyWith(filteredCampaigns: filtered));
  }

  /// Search promo codes
  Future<void> _onSearchPromoCodes(
    SearchPromoCodes event,
    Emitter<MarketingState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(promoCodeSearchQuery: query));

    if (query.isEmpty) {
      emit(state.copyWith(filteredPromoCodes: state.promoCodes));
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.promoCodes
        .where((p) => p.code.toLowerCase().contains(lowerQuery))
        .toList();

    emit(state.copyWith(filteredPromoCodes: filtered));
  }

  /// Toggle promo code status
  Future<void> _onTogglePromoCodeStatus(
    TogglePromoCodeStatus event,
    Emitter<MarketingState> emit,
  ) async {
    emit(state.copyWith(actionInProgressId: event.promoId));

    final result = await _repository.togglePromoCodeStatus(
      event.promoId,
      event.currentStatus,
    );

    result.when(
      success: (updatedPromo) {
        // Update the promo code in both lists
        final updatedCodes = state.promoCodes.map((p) {
          if (p.id == event.promoId) {
            return updatedPromo;
          }
          return p;
        }).toList();

        final updatedFiltered = state.filteredPromoCodes.map((p) {
          if (p.id == event.promoId) {
            return updatedPromo;
          }
          return p;
        }).toList();

        emit(
          state.copyWith(
            promoCodes: updatedCodes,
            filteredPromoCodes: updatedFiltered,
            clearActionInProgress: true,
          ),
        );
      },
      failure: (error) {
        emit(state.copyWith(error: error, clearActionInProgress: true));
      },
    );
  }

  /// Refresh all data
  Future<void> _onRefreshMarketingData(
    RefreshMarketingData event,
    Emitter<MarketingState> emit,
  ) async {
    add(const LoadMarketingData());
  }

  /// Clear search
  void _onClearSearch(ClearSearch event, Emitter<MarketingState> emit) {
    if (state.currentTab == MarketingTab.campaigns) {
      emit(
        state.copyWith(
          campaignSearchQuery: '',
          filteredCampaigns: state.campaigns,
        ),
      );
    } else {
      emit(
        state.copyWith(
          promoCodeSearchQuery: '',
          filteredPromoCodes: state.promoCodes,
        ),
      );
    }
  }

  /// Retry after failure
  Future<void> _onRetryLoad(
    RetryMarketingLoad event,
    Emitter<MarketingState> emit,
  ) async {
    emit(state.copyWith(clearError: true));
    add(const LoadMarketingData());
  }
}
