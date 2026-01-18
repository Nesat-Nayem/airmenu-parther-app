import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';

/// Mock data source for marketing feature
/// Replace with API calls when backend is ready
class MarketingMockDataSource {
  /// Simulate network delay
  static Future<void> _simulateDelay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Get mock marketing statistics
  static Future<MarketingStatsModel> getMarketingStats() async {
    await _simulateDelay();

    return const MarketingStatsModel(
      activeCampaigns: 12,
      activeCampaignsChange: 0,
      activeCampaignsIsPositive: true,
      usersReached: '45.2K',
      usersReachedChange: 25,
      usersReachedIsPositive: true,
      conversionRate: 3.8,
      conversionRateChange: 0.5,
      conversionRateIsPositive: true,
      activeOffers: 89,
      activeOffersChange: 0,
      activeOffersIsPositive: true,
    );
  }

  /// Get mock campaigns list
  static Future<List<CampaignModel>> getCampaigns() async {
    await _simulateDelay();

    return [
      CampaignModel(
        id: 'camp_001',
        name: 'Weekend Feast 20% Off',
        type: 'discount',
        status: 'active',
        startDate: DateTime(2024, 12, 8),
        endDate: DateTime(2024, 12, 15),
        reach: 45200,
        clicks: 3456,
        orders: 234,
        revenue: 234000,
        restaurantCount: 45,
      ),
      CampaignModel(
        id: 'camp_002',
        name: 'New Year Celebration',
        type: 'promo',
        status: 'scheduled',
        startDate: DateTime(2024, 12, 28),
        endDate: DateTime(2025, 1, 2),
        reach: 0,
        clicks: 0,
        orders: 0,
        revenue: 0,
        restaurantCount: 120,
      ),
      CampaignModel(
        id: 'camp_003',
        name: 'Theatre Combo Offer',
        type: 'promo',
        status: 'active',
        startDate: DateTime(2024, 12, 1),
        endDate: DateTime(2024, 12, 31),
        reach: 28500,
        clicks: 2189,
        orders: 156,
        revenue: 158000,
        restaurantCount: 45,
      ),
      CampaignModel(
        id: 'camp_004',
        name: 'Free Delivery Week',
        type: 'delivery',
        status: 'ended',
        startDate: DateTime(2024, 11, 25),
        endDate: DateTime(2024, 12, 1),
        reach: 67800,
        clicks: 8945,
        orders: 587,
        revenue: 456000,
        restaurantCount: 89,
      ),
    ];
  }

  /// Get mock promo codes list
  static Future<List<PromoCodeModel>> getPromoCodes() async {
    await _simulateDelay();

    return const [
      PromoCodeModel(
        id: 'promo_001',
        code: 'FLAT50',
        discountType: 'flat',
        discountValue: 50,
        minOrder: 200,
        uses: 1234,
        status: 'active',
      ),
      PromoCodeModel(
        id: 'promo_002',
        code: 'NEWUSER',
        discountType: 'percentage',
        discountValue: 20,
        minOrder: 150,
        uses: 567,
        status: 'active',
      ),
      PromoCodeModel(
        id: 'promo_003',
        code: 'WEEKEND30',
        discountType: 'percentage',
        discountValue: 30,
        minOrder: 300,
        uses: 890,
        status: 'active',
      ),
      PromoCodeModel(
        id: 'promo_004',
        code: 'BIRYANI20',
        discountType: 'percentage',
        discountValue: 20,
        minOrder: 250,
        uses: 456,
        status: 'paused',
      ),
      PromoCodeModel(
        id: 'promo_005',
        code: 'DESSERT15',
        discountType: 'percentage',
        discountValue: 15,
        minOrder: 100,
        uses: 234,
        status: 'active',
      ),
    ];
  }

  /// Get mock marketing summary
  static Future<MarketingSummaryModel> getMarketingSummary() async {
    await _simulateDelay();

    return MarketingSummaryModel(
      bestPerforming: const BestPerformingData(
        campaignName: 'Free Delivery Week',
        conversions: 587,
        revenue: 456000,
      ),
      mostUsedCode: const MostUsedCodeData(code: 'FLAT50', usesThisMonth: 1234),
      upcoming: UpcomingCampaignData(
        campaignName: 'New Year Celebration',
        startDate: DateTime(2024, 12, 28),
        restaurantCount: 120,
      ),
    );
  }

  /// Search campaigns by name
  static Future<List<CampaignModel>> searchCampaigns(String query) async {
    final allCampaigns = await getCampaigns();

    if (query.isEmpty) return allCampaigns;

    final lowerQuery = query.toLowerCase();
    return allCampaigns
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Search promo codes by code name
  static Future<List<PromoCodeModel>> searchPromoCodes(String query) async {
    final allCodes = await getPromoCodes();

    if (query.isEmpty) return allCodes;

    final lowerQuery = query.toLowerCase();
    return allCodes
        .where((p) => p.code.toLowerCase().contains(lowerQuery))
        .toList();
  }

  /// Toggle promo code status
  static Future<PromoCodeModel> togglePromoCodeStatus(
    String promoId,
    String currentStatus,
  ) async {
    await _simulateDelay();

    final allCodes = await getPromoCodes();
    final codeIndex = allCodes.indexWhere((p) => p.id == promoId);

    if (codeIndex == -1) {
      throw Exception('Promo code not found');
    }

    final newStatus = currentStatus == 'active' ? 'paused' : 'active';
    return allCodes[codeIndex].copyWith(status: newStatus);
  }
}
