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
  final MarketingLoadStatus summaryStatus;

  /// Data
  final MarketingStatsModel stats;
  final List<CampaignModel> campaigns;
  final List<CampaignModel> filteredCampaigns;
  final List<PromoCodeModel> promoCodes;
  final List<PromoCodeModel> filteredPromoCodes;
  final MarketingSummaryModel summary;

  /// Search queries
  final String campaignSearchQuery;
  final String promoCodeSearchQuery;

  /// Error state
  final MarketingError? error;

  /// Action in progress (for button loading states)
  final String? actionInProgressId;

  const MarketingState({
    this.currentTab = MarketingTab.campaigns,
    this.statsStatus = MarketingLoadStatus.initial,
    this.campaignsStatus = MarketingLoadStatus.initial,
    this.promoCodesStatus = MarketingLoadStatus.initial,
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
    this.summary = const MarketingSummaryModel(),
    this.campaignSearchQuery = '',
    this.promoCodeSearchQuery = '',
    this.error,
    this.actionInProgressId,
  });

  /// Factory for initial state
  factory MarketingState.initial() => const MarketingState();

  /// Check if any data is loading
  bool get isLoading =>
      statsStatus == MarketingLoadStatus.loading ||
      campaignsStatus == MarketingLoadStatus.loading ||
      promoCodesStatus == MarketingLoadStatus.loading;

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

  /// Get current search query based on active tab
  String get currentSearchQuery => currentTab == MarketingTab.campaigns
      ? campaignSearchQuery
      : promoCodeSearchQuery;

  /// Check if search is active
  bool get isSearchActive => currentSearchQuery.isNotEmpty;

  @override
  List<Object?> get props => [
    currentTab,
    statsStatus,
    campaignsStatus,
    promoCodesStatus,
    summaryStatus,
    stats,
    campaigns,
    filteredCampaigns,
    promoCodes,
    filteredPromoCodes,
    summary,
    campaignSearchQuery,
    promoCodeSearchQuery,
    error,
    actionInProgressId,
  ];

  MarketingState copyWith({
    MarketingTab? currentTab,
    MarketingLoadStatus? statsStatus,
    MarketingLoadStatus? campaignsStatus,
    MarketingLoadStatus? promoCodesStatus,
    MarketingLoadStatus? summaryStatus,
    MarketingStatsModel? stats,
    List<CampaignModel>? campaigns,
    List<CampaignModel>? filteredCampaigns,
    List<PromoCodeModel>? promoCodes,
    List<PromoCodeModel>? filteredPromoCodes,
    MarketingSummaryModel? summary,
    String? campaignSearchQuery,
    String? promoCodeSearchQuery,
    MarketingError? error,
    String? actionInProgressId,
    bool clearError = false,
    bool clearActionInProgress = false,
  }) {
    return MarketingState(
      currentTab: currentTab ?? this.currentTab,
      statsStatus: statsStatus ?? this.statsStatus,
      campaignsStatus: campaignsStatus ?? this.campaignsStatus,
      promoCodesStatus: promoCodesStatus ?? this.promoCodesStatus,
      summaryStatus: summaryStatus ?? this.summaryStatus,
      stats: stats ?? this.stats,
      campaigns: campaigns ?? this.campaigns,
      filteredCampaigns: filteredCampaigns ?? this.filteredCampaigns,
      promoCodes: promoCodes ?? this.promoCodes,
      filteredPromoCodes: filteredPromoCodes ?? this.filteredPromoCodes,
      summary: summary ?? this.summary,
      campaignSearchQuery: campaignSearchQuery ?? this.campaignSearchQuery,
      promoCodeSearchQuery: promoCodeSearchQuery ?? this.promoCodeSearchQuery,
      error: clearError ? null : (error ?? this.error),
      actionInProgressId: clearActionInProgress
          ? null
          : (actionInProgressId ?? this.actionInProgressId),
    );
  }
}

/// Load status enum for different data types
enum MarketingLoadStatus { initial, loading, success, failure, empty }
