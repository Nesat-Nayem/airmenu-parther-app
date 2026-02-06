import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_state.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';

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
    on<CreateCampaign>(_onCreateCampaign);
    on<UpdateCampaign>(_onUpdateCampaign);
    on<CreatePromoCode>(_onCreatePromoCode);
    on<UpdatePromoCode>(_onUpdatePromoCode);
    on<CreateCombo>(_onCreateCombo);
    on<SearchCombos>(_onSearchCombos);
  }

  /// Load all marketing data in parallel
  Future<void> _onLoadMarketingData(
    LoadMarketingData event,
    Emitter<MarketingState> emit,
  ) async {
    // Check admin status first
    final isAdmin = await _repository.isAdmin();

    emit(
      state.copyWith(
        statsStatus: MarketingLoadStatus.loading,
        campaignsStatus: MarketingLoadStatus.loading,
        promoCodesStatus: MarketingLoadStatus.loading,
        summaryStatus: MarketingLoadStatus.loading,
        clearError: true,
        isAdmin: isAdmin,
      ),
    );

    // Load all data in parallel for better performance
    final results = await Future.wait([
      _repository.getMarketingStats(),
      _repository.getCampaigns(),
      _repository.getPromoCodes(),
      _repository.getMarketingSummary(),
      if (!isAdmin) _repository.getCombos(),
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

    // Process combos result (only if not admin)
    if (!isAdmin && results.length > 4) {
      final combosResult = results[4] as MarketingResult<List<ComboModel>>;
      combosResult.when(
        success: (data) {
          emit(
            state.copyWith(
              combos: data,
              filteredCombos: data,
              combosStatus: data.isEmpty
                  ? MarketingLoadStatus.empty
                  : MarketingLoadStatus.success,
            ),
          );
        },
        failure: (error) {
          emit(
            state.copyWith(
              combosStatus: MarketingLoadStatus.failure,
              error: error,
            ),
          );
        },
      );
    }
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

  /// Search combos
  Future<void> _onSearchCombos(
    SearchCombos event,
    Emitter<MarketingState> emit,
  ) async {
    final query = event.query.trim();
    emit(state.copyWith(comboSearchQuery: query));

    if (query.isEmpty) {
      emit(state.copyWith(filteredCombos: state.combos));
      return;
    }

    final lowerQuery = query.toLowerCase();
    final filtered = state.combos
        .where((c) => c.title.toLowerCase().contains(lowerQuery))
        .toList();

    emit(state.copyWith(filteredCombos: filtered));
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

  Future<void> _onCreateCampaign(
    CreateCampaign event,
    Emitter<MarketingState> emit,
  ) async {
    // Handle both campaign form data and offer form data
    final data = event.campaignData;

    // Parse dates - support both 'startDate'/'endDate' and 'expiresAt'
    DateTime? startDate = DateTime.tryParse(data['startDate'] ?? '');
    DateTime? endDate = DateTime.tryParse(data['endDate'] ?? '');

    // If no startDate provided, use now
    startDate ??= DateTime.now();

    // If expiresAt is provided (from offer form), use it as endDate
    if (endDate == null && data['expiresAt'] != null) {
      endDate = DateTime.tryParse(data['expiresAt']);
    }

    // Default to 30 days from now if no end date
    endDate ??= DateTime.now().add(const Duration(days: 30));

    final campaign = CampaignModel(
      id: '',
      name: data['name'] ?? data['code'] ?? 'Unnamed Offer',
      type: data['type'] ?? 'discount',
      status: data['status'] ?? 'active',
      startDate: startDate,
      endDate: endDate,
      reach: 0,
      clicks: 0,
      orders: 0,
      revenue: 0.0,
      restaurantCount: 0,
      // Offer-specific fields
      description: data['description'] as String?,
      discountType: data['discountType'] ?? 'percentage',
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0,
      minOrderValue: (data['minOrder'] as num?)?.toDouble() ?? 0,
      maxDiscount: (data['maxDiscount'] as num?)?.toDouble(),
      offerType: data['offerType'] ?? 'restaurant',
      usageLimit: data['usageLimit'] as int?,
    );

    final result = await _repository.createCampaign(campaign);

    result.when(
      success: (newCampaign) {
        final currentCampaigns = List<CampaignModel>.from(state.campaigns);
        currentCampaigns.insert(0, newCampaign);
        emit(
          state.copyWith(
            campaigns: currentCampaigns,
            filteredCampaigns: currentCampaigns,
          ),
        );
        add(const LoadMarketingData()); // Reload to be safe
      },
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }

  Future<void> _onUpdateCampaign(
    UpdateCampaign event,
    Emitter<MarketingState> emit,
  ) async {
    final oldCampaign = state.campaigns.firstWhere(
      (c) => c.id == event.campaignId,
    );
    final campaign = oldCampaign.copyWith(
      name: event.campaignData['name'],
      type: event.campaignData['type'],
      status: event.campaignData['status'],
      startDate: DateTime.tryParse(event.campaignData['startDate'] ?? ''),
      endDate: DateTime.tryParse(event.campaignData['endDate'] ?? ''),
    );

    final result = await _repository.updateCampaign(campaign);

    result.when(
      success: (updatedCampaign) {
        final currentCampaigns = state.campaigns.map((c) {
          return c.id == updatedCampaign.id ? updatedCampaign : c;
        }).toList();

        emit(
          state.copyWith(
            campaigns: currentCampaigns,
            filteredCampaigns:
                currentCampaigns, // Simplified re-filter logic logic omitted for brevity, reload handles it
          ),
        );
        add(const LoadMarketingData());
      },
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }

  Future<void> _onCreatePromoCode(
    CreatePromoCode event,
    Emitter<MarketingState> emit,
  ) async {
    final promo = PromoCodeModel(
      id: '',
      code: event.promoData['code'],
      discountValue: event.promoData['discountValue'],
      discountType: event.promoData['discountType'],
      minOrder: event.promoData['minOrder'],
      status: 'active',
      uses: 0,
      expiresAt: event.promoData['expiresAt'] != null
          ? DateTime.parse(event.promoData['expiresAt'])
          : null,
    );

    final result = await _repository.createPromoCode(promo);
    result.when(
      success: (_) => add(const LoadMarketingData()),
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }

  Future<void> _onUpdatePromoCode(
    UpdatePromoCode event,
    Emitter<MarketingState> emit,
  ) async {
    // Fetch old promo to copy properties not in form if needed, but for now simplistic approach
    // In real app, we'd probably fetch or find in list.
    final oldPromo = state.promoCodes.firstWhere((p) => p.id == event.promoId);
    final promo = oldPromo.copyWith(
      code: event.promoData['code'],
      discountValue: event.promoData['discountValue'],
      discountType: event.promoData['discountType'],
      minOrder: event.promoData['minOrder'],
      expiresAt: event.promoData['expiresAt'] != null
          ? DateTime.parse(event.promoData['expiresAt'])
          : null,
    );

    final result = await _repository.updatePromoCode(promo);
    result.when(
      success: (_) => add(const LoadMarketingData()),
      failure: (error) => emit(state.copyWith(error: error)),
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
    } else if (state.currentTab == MarketingTab.promoCodes) {
      emit(
        state.copyWith(
          promoCodeSearchQuery: '',
          filteredPromoCodes: state.promoCodes,
        ),
      );
    } else if (state.currentTab == MarketingTab.combos) {
      emit(state.copyWith(comboSearchQuery: '', filteredCombos: state.combos));
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

  Future<void> _onCreateCombo(
    CreateCombo event,
    Emitter<MarketingState> emit,
  ) async {
    final data = event.comboData;

    // Parse items
    List<ComboItemModel> items = [];
    if (data['items'] != null) {
      items = (data['items'] as List)
          .map((e) => ComboItemModel.fromJson(e))
          .toList();
    }

    final combo = ComboModel(
      id: '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      items: items,
      originalPrice: (data['originalPrice'] as num?)?.toDouble() ?? 0,
      comboPrice: (data['comboPrice'] as num?)?.toDouble() ?? 0,
      savings: (data['savings'] as num?)?.toDouble() ?? 0,
      isActive: true,
      orderCount: 0,
      validDays:
          (data['validDays'] as List?)?.map((e) => e.toString()).toList() ??
          const [
            'monday',
            'tuesday',
            'wednesday',
            'thursday',
            'friday',
            'saturday',
            'sunday',
          ],
      usageLimit: data['usageLimit'] as int?,
    );

    final result = await _repository.createCombo(combo);

    result.when(
      success: (_) => add(const LoadMarketingData()),
      failure: (error) => emit(state.copyWith(error: error)),
    );
  }
}
