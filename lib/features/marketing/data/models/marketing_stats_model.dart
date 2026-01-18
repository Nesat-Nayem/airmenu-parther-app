import 'package:flutter/material.dart';

/// Model for marketing statistics
class MarketingStatsModel {
  final int activeCampaigns;
  final double activeCampaignsChange;
  final bool activeCampaignsIsPositive;
  final String usersReached;
  final double usersReachedChange;
  final bool usersReachedIsPositive;
  final double conversionRate;
  final double conversionRateChange;
  final bool conversionRateIsPositive;
  final int activeOffers;
  final double activeOffersChange;
  final bool activeOffersIsPositive;

  const MarketingStatsModel({
    required this.activeCampaigns,
    required this.activeCampaignsChange,
    required this.activeCampaignsIsPositive,
    required this.usersReached,
    required this.usersReachedChange,
    required this.usersReachedIsPositive,
    required this.conversionRate,
    required this.conversionRateChange,
    required this.conversionRateIsPositive,
    required this.activeOffers,
    required this.activeOffersChange,
    required this.activeOffersIsPositive,
  });

  /// Factory constructor with null safety and defaults
  factory MarketingStatsModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketingStatsModel.empty();

    return MarketingStatsModel(
      activeCampaigns: (json['activeCampaigns'] as int?) ?? 0,
      activeCampaignsChange:
          (json['activeCampaignsChange'] as num?)?.toDouble() ?? 0.0,
      activeCampaignsIsPositive:
          (json['activeCampaignsIsPositive'] as bool?) ?? true,
      usersReached: (json['usersReached'] as String?) ?? '0',
      usersReachedChange:
          (json['usersReachedChange'] as num?)?.toDouble() ?? 0.0,
      usersReachedIsPositive: (json['usersReachedIsPositive'] as bool?) ?? true,
      conversionRate: (json['conversionRate'] as num?)?.toDouble() ?? 0.0,
      conversionRateChange:
          (json['conversionRateChange'] as num?)?.toDouble() ?? 0.0,
      conversionRateIsPositive:
          (json['conversionRateIsPositive'] as bool?) ?? true,
      activeOffers: (json['activeOffers'] as int?) ?? 0,
      activeOffersChange:
          (json['activeOffersChange'] as num?)?.toDouble() ?? 0.0,
      activeOffersIsPositive: (json['activeOffersIsPositive'] as bool?) ?? true,
    );
  }

  /// Empty state factory
  factory MarketingStatsModel.empty() {
    return const MarketingStatsModel(
      activeCampaigns: 0,
      activeCampaignsChange: 0.0,
      activeCampaignsIsPositive: true,
      usersReached: '0',
      usersReachedChange: 0.0,
      usersReachedIsPositive: true,
      conversionRate: 0.0,
      conversionRateChange: 0.0,
      conversionRateIsPositive: true,
      activeOffers: 0,
      activeOffersChange: 0.0,
      activeOffersIsPositive: true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeCampaigns': activeCampaigns,
      'activeCampaignsChange': activeCampaignsChange,
      'activeCampaignsIsPositive': activeCampaignsIsPositive,
      'usersReached': usersReached,
      'usersReachedChange': usersReachedChange,
      'usersReachedIsPositive': usersReachedIsPositive,
      'conversionRate': conversionRate,
      'conversionRateChange': conversionRateChange,
      'conversionRateIsPositive': conversionRateIsPositive,
      'activeOffers': activeOffers,
      'activeOffersChange': activeOffersChange,
      'activeOffersIsPositive': activeOffersIsPositive,
    };
  }

  /// Convert to list of stat cards for UI
  List<MarketingStatCardData> toStatCards() {
    return [
      MarketingStatCardData(
        label: 'Active Campaigns',
        value: activeCampaigns.toString(),
        change: activeCampaignsChange > 0
            ? '${activeCampaignsChange.toStringAsFixed(0)}%'
            : '',
        isPositive: activeCampaignsIsPositive,
        icon: Icons.campaign_outlined,
        color: const Color(0xFFDC2626),
      ),
      MarketingStatCardData(
        label: 'Users Reached',
        value: usersReached,
        change: '${usersReachedChange.toStringAsFixed(0)}%',
        isPositive: usersReachedIsPositive,
        icon: Icons.people_outline,
        color: const Color(0xFFDC2626),
        subtitle: 'vs yesterday',
      ),
      MarketingStatCardData(
        label: 'Conversion Rate',
        value: '${conversionRate.toStringAsFixed(1)}%',
        change: '${conversionRateChange.toStringAsFixed(1)}%',
        isPositive: conversionRateIsPositive,
        icon: Icons.trending_up,
        color: const Color(0xFFDC2626),
        subtitle: 'vs yesterday',
      ),
      MarketingStatCardData(
        label: 'Active Offers',
        value: activeOffers.toString(),
        change: activeOffersChange > 0
            ? '${activeOffersChange.toStringAsFixed(0)}%'
            : '',
        isPositive: activeOffersIsPositive,
        icon: Icons.local_offer_outlined,
        color: const Color(0xFFDC2626),
      ),
    ];
  }

  MarketingStatsModel copyWith({
    int? activeCampaigns,
    double? activeCampaignsChange,
    bool? activeCampaignsIsPositive,
    String? usersReached,
    double? usersReachedChange,
    bool? usersReachedIsPositive,
    double? conversionRate,
    double? conversionRateChange,
    bool? conversionRateIsPositive,
    int? activeOffers,
    double? activeOffersChange,
    bool? activeOffersIsPositive,
  }) {
    return MarketingStatsModel(
      activeCampaigns: activeCampaigns ?? this.activeCampaigns,
      activeCampaignsChange:
          activeCampaignsChange ?? this.activeCampaignsChange,
      activeCampaignsIsPositive:
          activeCampaignsIsPositive ?? this.activeCampaignsIsPositive,
      usersReached: usersReached ?? this.usersReached,
      usersReachedChange: usersReachedChange ?? this.usersReachedChange,
      usersReachedIsPositive:
          usersReachedIsPositive ?? this.usersReachedIsPositive,
      conversionRate: conversionRate ?? this.conversionRate,
      conversionRateChange: conversionRateChange ?? this.conversionRateChange,
      conversionRateIsPositive:
          conversionRateIsPositive ?? this.conversionRateIsPositive,
      activeOffers: activeOffers ?? this.activeOffers,
      activeOffersChange: activeOffersChange ?? this.activeOffersChange,
      activeOffersIsPositive:
          activeOffersIsPositive ?? this.activeOffersIsPositive,
    );
  }
}

/// Helper class for stat card display
class MarketingStatCardData {
  final String label;
  final String value;
  final String change;
  final bool isPositive;
  final IconData icon;
  final Color color;
  final String? subtitle;

  const MarketingStatCardData({
    required this.label,
    required this.value,
    required this.change,
    required this.isPositive,
    required this.icon,
    required this.color,
    this.subtitle,
  });
}
