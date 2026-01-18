import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';

/// Model for marketing summary data (bottom tiles)
class MarketingSummaryModel {
  final BestPerformingData? bestPerforming;
  final MostUsedCodeData? mostUsedCode;
  final UpcomingCampaignData? upcoming;

  const MarketingSummaryModel({
    this.bestPerforming,
    this.mostUsedCode,
    this.upcoming,
  });

  factory MarketingSummaryModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const MarketingSummaryModel();

    return MarketingSummaryModel(
      bestPerforming: json['bestPerforming'] != null
          ? BestPerformingData.fromJson(
              json['bestPerforming'] as Map<String, dynamic>,
            )
          : null,
      mostUsedCode: json['mostUsedCode'] != null
          ? MostUsedCodeData.fromJson(
              json['mostUsedCode'] as Map<String, dynamic>,
            )
          : null,
      upcoming: json['upcoming'] != null
          ? UpcomingCampaignData.fromJson(
              json['upcoming'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  factory MarketingSummaryModel.empty() {
    return const MarketingSummaryModel();
  }

  bool get isEmpty =>
      bestPerforming == null && mostUsedCode == null && upcoming == null;

  MarketingSummaryModel copyWith({
    BestPerformingData? bestPerforming,
    MostUsedCodeData? mostUsedCode,
    UpcomingCampaignData? upcoming,
  }) {
    return MarketingSummaryModel(
      bestPerforming: bestPerforming ?? this.bestPerforming,
      mostUsedCode: mostUsedCode ?? this.mostUsedCode,
      upcoming: upcoming ?? this.upcoming,
    );
  }
}

/// Best performing campaign data
class BestPerformingData {
  final String campaignName;
  final int conversions;
  final double revenue;

  const BestPerformingData({
    required this.campaignName,
    required this.conversions,
    required this.revenue,
  });

  factory BestPerformingData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const BestPerformingData(
        campaignName: '',
        conversions: 0,
        revenue: 0.0,
      );
    }

    return BestPerformingData(
      campaignName: (json['campaignName'] as String?) ?? '',
      conversions: (json['conversions'] as int?) ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0.0,
    );
  }

  bool get isValid => campaignName.isNotEmpty;

  String get formattedRevenue {
    if (revenue >= 100000) {
      return '₹${(revenue / 100000).toStringAsFixed(2)}L';
    }
    return '₹${revenue.toInt()}';
  }

  String get formattedConversions {
    if (conversions >= 1000) {
      return '${(conversions / 1000).toStringAsFixed(1)}K';
    }
    return conversions.toString();
  }
}

/// Most used promo code data
class MostUsedCodeData {
  final String code;
  final int usesThisMonth;

  const MostUsedCodeData({required this.code, required this.usesThisMonth});

  factory MostUsedCodeData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const MostUsedCodeData(code: '', usesThisMonth: 0);
    }

    return MostUsedCodeData(
      code: (json['code'] as String?) ?? '',
      usesThisMonth: (json['usesThisMonth'] as int?) ?? 0,
    );
  }

  bool get isValid => code.isNotEmpty;

  String get formattedUses {
    if (usesThisMonth >= 1000) {
      return '${(usesThisMonth / 1000).toStringAsFixed(1)}K';
    }
    return usesThisMonth.toString();
  }
}

/// Upcoming campaign data
class UpcomingCampaignData {
  final String campaignName;
  final DateTime? startDate;
  final int restaurantCount;

  const UpcomingCampaignData({
    required this.campaignName,
    this.startDate,
    required this.restaurantCount,
  });

  factory UpcomingCampaignData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const UpcomingCampaignData(
        campaignName: '',
        startDate: null,
        restaurantCount: 0,
      );
    }

    DateTime? parsedDate;
    if (json['startDate'] != null) {
      try {
        parsedDate = DateTime.parse(json['startDate'] as String);
      } catch (_) {
        parsedDate = null;
      }
    }

    return UpcomingCampaignData(
      campaignName: (json['campaignName'] as String?) ?? '',
      startDate: parsedDate,
      restaurantCount: (json['restaurantCount'] as int?) ?? 0,
    );
  }

  bool get isValid => campaignName.isNotEmpty;

  String get formattedStartDate {
    if (startDate == null) return 'Date TBD';
    return CampaignModel.empty()
        .copyWith(startDate: startDate)
        .dateRangeDisplay
        .split(' to ')[0];
  }

  String get formattedDetails {
    final date = formattedStartDate;
    final restaurants = '$restaurantCount restaurants';
    return 'Starts $date • $restaurants';
  }
}
