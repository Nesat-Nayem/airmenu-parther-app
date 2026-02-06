import 'dart:convert';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/marketing/data/datasources/marketing_mock_datasource.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/campaign_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_stats_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/marketing_summary_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/promo_code_model.dart';
import 'package:airmenuai_partner_app/features/marketing/data/models/combo_model.dart';
import 'package:airmenuai_partner_app/features/marketing/domain/repositories/i_marketing_repository.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/services/user_service.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

/// Repository implementation for marketing feature
/// Handles both Admin and Vendor flows with appropriate API endpoints
@LazySingleton(as: IMarketingRepository)
class MarketingRepositoryImpl implements IMarketingRepository {
  final ApiService _apiService = locator<ApiService>();
  final UserService _userService = locator<UserService>();
  final LocalStorage _localStorage = locator<LocalStorage>();

  /// Get the current user's hotelId (for vendor)
  Future<String?> _getHotelId() async {
    return _localStorage.getString(localStorageKey: 'hotelId');
  }

  /// Check if the current user is an admin
  @override
  Future<bool> isAdmin() async {
    final user = await _userService.getCurrentUser();
    return user?.isAdmin ?? false;
  }

  // Internal helper kept for backward compatibility if needed, calling public method
  Future<bool> _isAdmin() => isAdmin();

  @override
  Future<MarketingResult<MarketingStatsModel>> getMarketingStats() async {
    try {
      // Stats still use mock for now (can be API-driven later)
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
      final isAdmin = await _isAdmin();

      if (isAdmin) {
        // Admin: Still use mock for campaigns (no campaign API yet)
        final campaigns = await MarketingMockDataSource.getCampaigns();
        return MarketingResult.success(campaigns);
      } else {
        // Vendor: Fetch offers from hotel-offers API
        final hotelId = await _getHotelId();
        if (hotelId == null || hotelId.isEmpty) {
          return MarketingResult.failure(
            MarketingError.validation(
              'No hotel ID found. Please select a restaurant.',
            ),
          );
        }

        final response = await _apiService.invoke<List<CampaignModel>>(
          urlPath: '/hotel-offers/hotel/$hotelId',
          type: RequestType.get,
          fun: (jsonString) {
            final map = jsonDecode(jsonString);
            final list = (map['data'] as List?) ?? [];
            return list.map((e) => CampaignModel.fromOfferJson(e)).toList();
          },
        );

        if (response is DataSuccess) {
          return MarketingResult.success(response.data ?? []);
        } else {
          final error = (response as DataFailure).error;
          return MarketingResult.failure(
            MarketingError.server(error?.message ?? 'Failed to load offers'),
          );
        }
      }
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
      // Get all campaigns and filter locally
      final result = await getCampaigns();
      if (!result.isSuccess) return result;

      final filtered = result.data!
          .where(
            (campaign) =>
                campaign.name.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return MarketingResult.success(filtered);
    } catch (e, stackTrace) {
      debugPrint('Error searching campaigns: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<PromoCodeModel>>> getPromoCodes() async {
    try {
      final isAdmin = await _isAdmin();
      String urlPath;

      if (isAdmin) {
        // Admin: Fetch global coupons
        urlPath = '/coupons/admin';
      } else {
        // Vendor: Fetch vendor's coupons
        urlPath = '/coupons/vendor';
      }

      final response = await _apiService.invoke<List<PromoCodeModel>>(
        urlPath: urlPath,
        type: RequestType.get,
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          final list = (map['data'] as List?) ?? [];
          return list.map((e) => PromoCodeModel.fromJson(e)).toList();
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data ?? []);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to load coupons'),
        );
      }
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
      // Get all and filter client-side for now
      final result = await getPromoCodes();
      if (!result.isSuccess) return result;

      final filtered = result.data!
          .where(
            (code) => code.code.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();

      return MarketingResult.success(filtered);
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

      final isAdmin = await _isAdmin();
      final newStatus = currentStatus == 'active' ? false : true;
      final urlPath = isAdmin ? '/coupons/admin/$promoId' : '/coupons/$promoId';

      final response = await _apiService.invoke<PromoCodeModel>(
        urlPath: urlPath,
        type: RequestType.put,
        params: {'isActive': newStatus},
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          return PromoCodeModel.fromJson(map['data']);
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data!);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to update coupon'),
        );
      }
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

      final isAdmin = await _isAdmin();

      if (isAdmin) {
        // Mock implementation for admin
        final createdCampaign = campaign.copyWith(
          id: 'camp_${DateTime.now().millisecondsSinceEpoch}',
        );
        return MarketingResult.success(createdCampaign);
      } else {
        // Vendor: Create offer via API
        final hotelId = await _getHotelId();
        if (hotelId == null || hotelId.isEmpty) {
          return MarketingResult.failure(
            MarketingError.validation('No hotel ID found'),
          );
        }

        final response = await _apiService.invoke<CampaignModel>(
          urlPath: '/hotel-offers/create',
          type: RequestType.post,
          params: campaign.toOfferJson(hotelId),
          fun: (jsonString) {
            final map = jsonDecode(jsonString);
            return CampaignModel.fromOfferJson(map['data']);
          },
        );

        if (response is DataSuccess) {
          return MarketingResult.success(response.data!);
        } else {
          final error = (response as DataFailure).error;
          return MarketingResult.failure(
            MarketingError.server(error?.message ?? 'Failed to create offer'),
          );
        }
      }
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

      final isAdmin = await _isAdmin();

      if (isAdmin) {
        // Mock implementation for admin
        return MarketingResult.success(campaign);
      } else {
        // Vendor: Update offer via API
        final response = await _apiService.invoke<CampaignModel>(
          urlPath: '/hotel-offers/${campaign.id}',
          type: RequestType.put,
          params: campaign.toOfferJson(null),
          fun: (jsonString) {
            final map = jsonDecode(jsonString);
            return CampaignModel.fromOfferJson(map['data']);
          },
        );

        if (response is DataSuccess) {
          return MarketingResult.success(response.data!);
        } else {
          final error = (response as DataFailure).error;
          return MarketingResult.failure(
            MarketingError.server(error?.message ?? 'Failed to update offer'),
          );
        }
      }
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

      final isAdmin = await _isAdmin();
      final urlPath = isAdmin ? '/coupons/admin' : '/coupons';

      final response = await _apiService.invoke<PromoCodeModel>(
        urlPath: urlPath,
        type: RequestType.post,
        params: promoCode.toJson(),
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          return PromoCodeModel.fromJson(map['data']);
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data!);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to create coupon'),
        );
      }
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

      final isAdmin = await _isAdmin();
      final urlPath = isAdmin
          ? '/coupons/admin/${promoCode.id}'
          : '/coupons/${promoCode.id}';

      final response = await _apiService.invoke<PromoCodeModel>(
        urlPath: urlPath,
        type: RequestType.put,
        params: promoCode.toJson(),
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          return PromoCodeModel.fromJson(map['data']);
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data!);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to update coupon'),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error updating promo code: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<List<ComboModel>>> getCombos() async {
    try {
      final hotelId = await _getHotelId();
      if (hotelId == null || hotelId.isEmpty) {
        return MarketingResult.failure(
          MarketingError.validation('No hotel ID found'),
        );
      }

      final response = await _apiService.invoke<List<ComboModel>>(
        urlPath: '/combos/hotel/$hotelId',
        type: RequestType.get,
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          final list = (map['data']['combos'] as List?) ?? [];
          return list.map((e) => ComboModel.fromJson(e)).toList();
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data ?? []);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to load combos'),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error fetching combos: $e\n$stackTrace');
      return MarketingResult.failure(_handleError(e));
    }
  }

  @override
  Future<MarketingResult<ComboModel>> createCombo(ComboModel combo) async {
    try {
      final hotelId = await _getHotelId();
      if (hotelId == null || hotelId.isEmpty) {
        return MarketingResult.failure(
          MarketingError.validation('No hotel ID found'),
        );
      }

      // Ensure at least 2 items
      if (combo.items.length < 2) {
        return MarketingResult.failure(
          MarketingError.validation('A combo must have at least 2 items'),
        );
      }

      final response = await _apiService.invoke<ComboModel>(
        urlPath: '/combos/create',
        type: RequestType.post,
        params: combo.toJson(hotelId: hotelId),
        fun: (jsonString) {
          final map = jsonDecode(jsonString);
          return ComboModel.fromJson(map['data']);
        },
      );

      if (response is DataSuccess) {
        return MarketingResult.success(response.data!);
      } else {
        final error = (response as DataFailure).error;
        return MarketingResult.failure(
          MarketingError.server(error?.message ?? 'Failed to create combo'),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error creating combo: $e\n$stackTrace');
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
