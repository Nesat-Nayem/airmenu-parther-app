import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';
import 'package:equatable/equatable.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/features/marketing/presentation/bloc/marketing_event.dart';

/// State for Marketing BLoC
class MarketingState extends Equatable {
  /// Current active tab
  final MarketingTab currentTab;

  /// Loading states
  final MarketingLoadStatus statsStatus;
  final MarketingLoadStatus campaignsStatus;
  final MarketingLoadStatus promoCodesStatus;
  final MarketingLoadStatus combosStatus;
  final MarketingLoadStatus summaryStatus;

  /// Data
  final MarketingStatsModel stats;
  final List<CampaignModel> campaigns;
  final List<CampaignModel> filteredCampaigns;
  final List<PromoCodeModel> promoCodes;
  final List<PromoCodeModel> filteredPromoCodes;
  final List<ComboModel> combos;
  final List<ComboModel> filteredCombos;
  final MarketingSummaryModel summary;

  /// Search queries
  final String campaignSearchQuery;
  final String promoCodeSearchQuery;
  final String comboSearchQuery;

  /// Error state
  final MarketingError? error;

  /// Action in progress (for button loading states)
  final String? actionInProgressId;

  /// Role flag
  final bool isAdmin;

  const MarketingState({
    this.currentTab = MarketingTab.campaigns,
    this.statsStatus = MarketingLoadStatus.initial,
    this.campaignsStatus = MarketingLoadStatus.initial,
    this.promoCodesStatus = MarketingLoadStatus.initial,
    this.combosStatus = MarketingLoadStatus.initial,
    this.summaryStatus = MarketingLoadStatus.initial,
    this.stats = const MarketingStatsModel(
      activeCampaigns: 0,
      activeCampaignsChange: 0,
      activeCampaignsIsPositive: true,
      usersReached: '0',
      usersReachedChange: 0,
      usersReachedIsPositive: true,
      conversionRate: 0,
      conversionRateChange: 0,
      conversionRateIsPositive: true,
      activeOffers: 0,
      activeOffersChange: 0,
      activeOffersIsPositive: true,
    ),
    this.campaigns = const [],
    this.filteredCampaigns = const [],
    this.promoCodes = const [],
    this.filteredPromoCodes = const [],
    this.combos = const [],
    this.filteredCombos = const [],
    this.summary = const MarketingSummaryModel(),
    this.campaignSearchQuery = '',
    this.promoCodeSearchQuery = '',
    this.comboSearchQuery = '',
    this.error,
    this.actionInProgressId,
    this.isAdmin = false,
  });

  /// Factory for initial state
  factory MarketingState.initial() => const MarketingState();

  /// Check if any data is loading
  bool get isLoading =>
      statsStatus == MarketingLoadStatus.loading ||
      campaignsStatus == MarketingLoadStatus.loading ||
      promoCodesStatus == MarketingLoadStatus.loading ||
      combosStatus == MarketingLoadStatus.loading;

  /// Check if all data loaded successfully
  bool get isSuccess =>
      statsStatus == MarketingLoadStatus.success &&
      campaignsStatus == MarketingLoadStatus.success &&
      promoCodesStatus == MarketingLoadStatus.success;

  /// Check if there's an error
  bool get hasError => error != null;

  /// Check if campaigns are empty (after loading)
  bool get isCampaignsEmpty =>
      campaignsStatus == MarketingLoadStatus.success &&
      filteredCampaigns.isEmpty;

  /// Check if promo codes are empty (after loading)
  bool get isPromoCodesEmpty =>
      promoCodesStatus == MarketingLoadStatus.success &&
      filteredPromoCodes.isEmpty;

  /// Check if combos are empty (after loading)
  bool get isCombosEmpty =>
      combosStatus == MarketingLoadStatus.success && filteredCombos.isEmpty;

  /// Get current search query based on active tab
  String get currentSearchQuery {
    switch (currentTab) {
      case MarketingTab.campaigns:
        return campaignSearchQuery;
      case MarketingTab.promoCodes:
        return promoCodeSearchQuery;
      case MarketingTab.combos:
        return comboSearchQuery;
    }
  }

  /// Check if search is active
  bool get isSearchActive => currentSearchQuery.isNotEmpty;

  @override
  List<Object?> get props => [
    currentTab,
    statsStatus,
    campaignsStatus,
    promoCodesStatus,
    combosStatus,
    summaryStatus,
    stats,
    campaigns,
    filteredCampaigns,
    promoCodes,
    filteredPromoCodes,
    combos,
    filteredCombos,
    summary,
    campaignSearchQuery,
    promoCodeSearchQuery,
    comboSearchQuery,
    error,
    actionInProgressId,
    isAdmin,
  ];

  MarketingState copyWith({
    MarketingTab? currentTab,
    MarketingLoadStatus? statsStatus,
    MarketingLoadStatus? campaignsStatus,
    MarketingLoadStatus? promoCodesStatus,
    MarketingLoadStatus? combosStatus,
    MarketingLoadStatus? summaryStatus,
    MarketingStatsModel? stats,
    List<CampaignModel>? campaigns,
    List<CampaignModel>? filteredCampaigns,
    List<PromoCodeModel>? promoCodes,
    List<PromoCodeModel>? filteredPromoCodes,
    List<ComboModel>? combos,
    List<ComboModel>? filteredCombos,
    MarketingSummaryModel? summary,
    String? campaignSearchQuery,
    String? promoCodeSearchQuery,
    String? comboSearchQuery,
    MarketingError? error,
    String? actionInProgressId,
    bool clearError = false,
    bool clearActionInProgress = false,
    bool? isAdmin,
  }) {
    return MarketingState(
      currentTab: currentTab ?? this.currentTab,
      statsStatus: statsStatus ?? this.statsStatus,
      campaignsStatus: campaignsStatus ?? this.campaignsStatus,
      promoCodesStatus: promoCodesStatus ?? this.promoCodesStatus,
      combosStatus: combosStatus ?? this.combosStatus,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      stats: stats ?? this.stats,
      campaigns: campaigns ?? this.campaigns,
      filteredCampaigns: filteredCampaigns ?? this.filteredCampaigns,
      promoCodes: promoCodes ?? this.promoCodes,
      filteredPromoCodes: filteredPromoCodes ?? this.filteredPromoCodes,
      combos: combos ?? this.combos,
      filteredCombos: filteredCombos ?? this.filteredCombos,
      summary: summary ?? this.summary,
      campaignSearchQuery: campaignSearchQuery ?? this.campaignSearchQuery,
      promoCodeSearchQuery: promoCodeSearchQuery ?? this.promoCodeSearchQuery,
      comboSearchQuery: comboSearchQuery ?? this.comboSearchQuery,
      error: clearError ? null : (error ?? this.error),
      actionInProgressId: clearActionInProgress
          ? null
          : (actionInProgressId ?? this.actionInProgressId),
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

/// Load status enum for different data types
enum MarketingLoadStatus { initial, loading, success, failure, empty }
