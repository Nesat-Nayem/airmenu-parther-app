import 'package:airmenuai_partner_app/features/marketing/data/datasources/marketing_mock_datasource.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:flutter/foundation.dart';

/// Repository implementation for marketing feature
/// Currently uses mock data, can be switched to API when ready
class MarketingRepositoryImpl implements IMarketingRepository {
  @override
  Future<MarketingResult<MarketingStatsModel>> getMarketingStats() async {
    try {
      final stats = await MarketingMockDataSource.getMarketingStats();
      return MarketingResult.success(stats);
    } catch (e, stackTrace) {
      debugPrint('Error fetching marketing stats: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<CampaignModel>>> getCampaigns() async {
    try {
      final campaigns = await MarketingMockDataSource.getCampaigns();
      return MarketingResult.success(campaigns);
    } catch (e, stackTrace) {
      debugPrint('Error fetching campaigns: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<CampaignModel>>> searchCampaigns(
    String query,
  ) async {
    try {
      final campaigns = await MarketingMockDataSource.searchCampaigns(query);
      return MarketingResult.success(campaigns);
    } catch (e, stackTrace) {
      debugPrint('Error searching campaigns: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<PromoCodeModel>>> getPromoCodes() async {
    try {
      final promoCodes = await MarketingMockDataSource.getPromoCodes();
      return MarketingResult.success(promoCodes);
    } catch (e, stackTrace) {
      debugPrint('Error fetching promo codes: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<PromoCodeModel>>> searchPromoCodes(
    String query,
  ) async {
    try {
      final promoCodes = await MarketingMockDataSource.searchPromoCodes(query);
      return MarketingResult.success(promoCodes);
    } catch (e, stackTrace) {
      debugPrint('Error searching promo codes: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<MarketingSummaryModel>> getMarketingSummary() async {
    try {
      final summary = await MarketingMockDataSource.getMarketingSummary();
      return MarketingResult.success(summary);
    } catch (e, stackTrace) {
      debugPrint('Error fetching marketing summary: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<PromoCodeModel>> togglePromoCodeStatus(
    String promoId,
    String currentStatus,
  ) async {
    try {
      if (promoId.isEmpty) {
        return MarketingResult.failure(
          MarketingError.validation('Promo code ID is required'),
        );
      }

      final updatedCode = await MarketingMockDataSource.togglePromoCodeStatus(
        promoId,
        currentStatus,
      );
      return MarketingResult.success(updatedCode);
    } catch (e, stackTrace) {
      debugPrint('Error toggling promo code status: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<CampaignModel>> createCampaign(
    CampaignModel campaign,
  ) async {
    try {
      if (!campaign.isValid) {
        return MarketingResult.failure(
          MarketingError.validation('Campaign name is required'),
        );
      }

      // Mock implementation - return the same campaign with a generated ID
      final createdCampaign = campaign.copyWith(
        id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
      );
      return MarketingResult.success(createdCampaign);
    } catch (e, stackTrace) {
      debugPrint('Error creating campaign: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<CampaignModel>> updateCampaign(
    CampaignModel campaign,
  ) async {
    try {
      if (campaign.id.isEmpty) {
        return MarketingResult.failure(
          MarketingError.validation('Campaign ID is required'),
        );
      }

      // Mock implementation - return the updated campaign
      return MarketingResult.success(campaign);
    } catch (e, stackTrace) {
      debugPrint('Error updating campaign: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<PromoCodeModel>> createPromoCode(
    PromoCodeModel promoCode,
  ) async {
    try {
      if (!promoCode.isValid) {
        return MarketingResult.failure(
          MarketingError.validation('Promo code is required'),
        );
      }

      // Mock implementation - return the same promo with a generated ID
      final createdPromo = promoCode.copyWith(
        id: 'promo_${DateTime.now().millisecondsSinceEpoch}',
      );
      return MarketingResult.success(createdPromo);
    } catch (e, stackTrace) {
      debugPrint('Error creating promo code: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<PromoCodeModel>> updatePromoCode(
    PromoCodeModel promoCode,
  ) async {
    try {
      if (promoCode.id.isEmpty) {
        return MarketingResult.failure(
          MarketingError.validation('Promo code ID is required'),
        );
      }

      // Mock implementation - return the updated promo
      return MarketingResult.success(promoCode);
    } catch (e, stackTrace) {
      debugPrint('Error updating promo code: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  /// Handle different types of errors
  MarketingError _handleError(dynamic error) {
    if (error is MarketingError) {
      return error;
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('connection') ||
        errorString.contains('network') ||
        errorString.contains('socket')) {
      return MarketingError.network();
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return MarketingError.notFound();
    }

    if (errorString.contains('unauthorized') ||
        errorString.contains('401') ||
        errorString.contains('403')) {
      return MarketingError.unauthorized();
    }

    if (errorString.contains('500') || errorString.contains('server')) {
      return MarketingError.server();
    }

    return MarketingError.unknown(error);
  }
}
