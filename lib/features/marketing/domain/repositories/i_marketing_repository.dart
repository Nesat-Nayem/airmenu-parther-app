import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';

/// Repository interface for marketing feature
/// Defines all operations available for marketing data
abstract class IMarketingRepository {
  /// Get marketing statistics for dashboard tiles
  Future<MarketingResult<MarketingStatsModel>> getMarketingStats();

  /// Get all campaigns
  Future<MarketingResult<List<CampaignModel>>> getCampaigns();

  /// Search campaigns by query
  Future<MarketingResult<List<CampaignModel>>> searchCampaigns(String query);

  /// Get all promo codes
  Future<MarketingResult<List<PromoCodeModel>>> getPromoCodes();

  /// Search promo codes by query
  Future<MarketingResult<List<PromoCodeModel>>> searchPromoCodes(String query);

  /// Get marketing summary (best performing, most used, upcoming)
  Future<MarketingResult<MarketingSummaryModel>> getMarketingSummary();

  /// Toggle promo code status (active/paused)
  Future<MarketingResult<PromoCodeModel>> togglePromoCodeStatus(
    String promoId,
    String currentStatus,
  );

  /// Create a new campaign
  Future<MarketingResult<CampaignModel>> createCampaign(CampaignModel campaign);

  /// Update an existing campaign
  Future<MarketingResult<CampaignModel>> updateCampaign(CampaignModel campaign);

  /// Create a new promo code
  Future<MarketingResult<PromoCodeModel>> createPromoCode(
    PromoCodeModel promoCode,
  );

  /// Update an existing promo code
  Future<MarketingResult<PromoCodeModel>> updatePromoCode(
    PromoCodeModel promoCode,
  );

  /// Check if current user is admin
  Future<bool> isAdmin();

  /// Get all combos (Vendor)
  Future<MarketingResult<List<ComboModel>>> getCombos();

  /// Create a new combo (Vendor)
  Future<MarketingResult<ComboModel>> createCombo(ComboModel combo);
}

/// Generic result wrapper for marketing operations
/// Follows Either pattern for error handling
class MarketingResult<T> {
  final T? data;
  final MarketingError? error;
  final bool isSuccess;

  const MarketingResult._({this.data, this.error, required this.isSuccess});

  /// Create a success result
  factory MarketingResult.success(T data) {
    return MarketingResult._(data: data, isSuccess: true);
  }

  /// Create a failure result
  factory MarketingResult.failure(MarketingError error) {
    return MarketingResult._(error: error, isSuccess: false);
  }

  /// Execute callback based on result
  R when<R>({
    required R Function(T data) success,
    required R Function(MarketingError error) failure,
  }) {
    if (isSuccess && data != null) {
      return success(data as T);
    }
    return failure(error ?? MarketingError.unknown());
  }

  /// Map success data to new type
  MarketingResult<R> map<R>(R Function(T data) mapper) {
    if (isSuccess && data != null) {
      return MarketingResult.success(mapper(data as T));
    }
    return MarketingResult.failure(error ?? MarketingError.unknown());
  }
}

/// Error types for marketing operations
class MarketingError {
  final String message;
  final MarketingErrorType type;
  final dynamic originalError;

  const MarketingError({
    required this.message,
    required this.type,
    this.originalError,
  });

  factory MarketingError.network([String? message]) {
    return MarketingError(
      message: message ?? 'Network error. Please check your connection.',
      type: MarketingErrorType.network,
    );
  }

  factory MarketingError.server([String? message]) {
    return MarketingError(
      message: message ?? 'Server error. Please try again later.',
      type: MarketingErrorType.server,
    );
  }

  factory MarketingError.notFound([String? message]) {
    return MarketingError(
      message: message ?? 'The requested resource was not found.',
      type: MarketingErrorType.notFound,
    );
  }

  factory MarketingError.validation([String? message]) {
    return MarketingError(
      message: message ?? 'Invalid data provided.',
      type: MarketingErrorType.validation,
    );
  }

  factory MarketingError.unauthorized([String? message]) {
    return MarketingError(
      message: message ?? 'You are not authorized to perform this action.',
      type: MarketingErrorType.unauthorized,
    );
  }

  factory MarketingError.unknown([dynamic error]) {
    return MarketingError(
      message: 'An unexpected error occurred.',
      type: MarketingErrorType.unknown,
      originalError: error,
    );
  }

  @override
  String toString() => 'MarketingError($type): $message';
}

/// Types of marketing errors
enum MarketingErrorType {
  network,
  server,
  notFound,
  validation,
  unauthorized,
  unknown,
}
