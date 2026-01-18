import 'package:equatable/equatable.dart';

/// Base event class for Marketing BLoC
abstract class MarketingEvent extends Equatable {
  const MarketingEvent();

  @override
  List<Object?> get props => [];
}

/// Load all marketing data (stats, campaigns, promo codes, summary)
class LoadMarketingData extends MarketingEvent {
  const LoadMarketingData();
}

/// Switch between Campaigns and Promo Codes tabs
class SwitchMarketingTab extends MarketingEvent {
  final MarketingTab tab;

  const SwitchMarketingTab(this.tab);

  @override
  List<Object?> get props => [tab];
}

/// Search campaigns
class SearchCampaigns extends MarketingEvent {
  final String query;

  const SearchCampaigns(this.query);

  @override
  List<Object?> get props => [query];
}

/// Search promo codes
class SearchPromoCodes extends MarketingEvent {
  final String query;

  const SearchPromoCodes(this.query);

  @override
  List<Object?> get props => [query];
}

/// Toggle promo code status (active/paused)
class TogglePromoCodeStatus extends MarketingEvent {
  final String promoId;
  final String currentStatus;

  const TogglePromoCodeStatus({
    required this.promoId,
    required this.currentStatus,
  });

  @override
  List<Object?> get props => [promoId, currentStatus];
}

/// Refresh marketing data
class RefreshMarketingData extends MarketingEvent {
  const RefreshMarketingData();
}

/// Clear search query
class ClearSearch extends MarketingEvent {
  const ClearSearch();
}

/// Retry after failure
class RetryMarketingLoad extends MarketingEvent {
  const RetryMarketingLoad();
}

/// Tab enum for marketing page
enum MarketingTab { campaigns, promoCodes }
