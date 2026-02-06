import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/admin_restaurant_models.dart';
import 'package:airmenuai_partner_app/features/restaurants/data/models/admin/restaurant_creation_models.dart';

import 'package:injectable/injectable.dart';

/// Repository for admin restaurants data
@lazySingleton
class AdminRestaurantsRepository {
  final ApiService _apiService;

  AdminRestaurantsRepository(this._apiService);

  /// Get restaurant statistics
  Future<RestaurantStatsModel> getRestaurantStats() async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.hotels,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        final pagination = data['pagination'] as Map<String, dynamic>? ?? {};
        final total = pagination['total'] as int? ?? 0;

        // For now, return mock stats since API doesn't provide status breakdown
        // TODO: Update when API provides status-based stats
        return RestaurantStatsModel(
          total: total,
          active: (total * 0.9).round(),
          pending: (total * 0.05).round(),
          suspended: (total * 0.05).round(),
        );
      } else {
        throw Exception('Failed to load restaurant stats');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant stats: $e');
    }
  }

  /// Get paginated list of restaurants with optional filters
  Future<RestaurantListResponseModel> getRestaurants({
    RestaurantFiltersModel? filters,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': pageSize.toString(),
      };

      if (filters != null) {
        final filterMap = filters.toJson();
        filterMap.forEach((key, value) {
          if (value != null) {
            queryParams[key] = value.toString();
          }
        });
      }

      final endpoint = ApiEndpoints.hotels + _buildQueryString(queryParams);

      final response = await _apiService.invoke(
        urlPath: endpoint,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        return RestaurantListResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to load restaurants');
      }
    } catch (e) {
      throw Exception('Error fetching restaurants: $e');
    }
  }

  /// Get restaurant details by ID
  Future<RestaurantModel> getRestaurantDetails({
    required String restaurantId,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.hotels}/$restaurantId',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] != null) {
          return RestaurantModel.fromJson(data['data']);
        }
        return RestaurantModel.fromJson(data);
      } else {
        throw Exception('Failed to load restaurant details');
      }
    } catch (e) {
      throw Exception('Error fetching restaurant details: $e');
    }
  }

  /// Update restaurant status
  Future<void> updateRestaurantStatus({
    required String restaurantId,
    required String status,
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.hotels}/$restaurantId',
        type: RequestType.patch,
        params: {'status': status},
        fun: (data) => jsonDecode(data),
      );

      if (response is! DataSuccess) {
        throw Exception('Failed to update restaurant status');
      }
    } catch (e) {
      throw Exception('Error updating restaurant status: $e');
    }
  }

  /// Delete restaurant
  Future<void> deleteRestaurant({required String restaurantId}) async {
    try {
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.hotels}/$restaurantId',
        type: RequestType.delete,
        fun: (data) => jsonDecode(data),
      );

      if (response is! DataSuccess) {
        throw Exception('Failed to delete restaurant');
      }
    } catch (e) {
      throw Exception('Error deleting restaurant: $e');
    }
  }

  /// Search restaurants by query
  Future<RestaurantListResponseModel> searchRestaurants({
    required String query,
    int page = 1,
    int pageSize = 10,
  }) async {
    final filters = RestaurantFiltersModel(searchQuery: query);
    return getRestaurants(filters: filters, page: page, pageSize: pageSize);
  }

  /// Create a new restaurant
  Future<void> createRestaurant({
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        // Convert dynamic data to Map<String, String> for fields
        final fields = data.map((key, value) {
          if (value is List || value is Map) {
            return MapEntry(key, jsonEncode(value));
          }
          return MapEntry(key, value.toString());
        });

        final response = await _apiService.invokeMultipart(
          urlPath: ApiEndpoints.hotels,
          type: RequestType.post,
          fields: fields,
          files: {'mainImage': imagePath},
          fun: (data) => jsonDecode(data),
        );

        if (response is! DataSuccess) {
          throw Exception('Failed to create restaurant');
        }
      } else {
        final response = await _apiService.invoke(
          urlPath: ApiEndpoints.hotels,
          type: RequestType.post,
          params: data,
          fun: (data) => jsonDecode(data),
        );

        if (response is! DataSuccess) {
          throw Exception('Failed to create restaurant');
        }
      }
    } catch (e) {
      throw Exception('Error creating restaurant: $e');
    }
  }

  /// Get address autocomplete suggestions
  Future<List<PlaceAutocompleteModel>> getAutocompleteSuggestions(
    String input,
  ) async {
    try {
      final encodedInput = Uri.encodeComponent(input);
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.placesAutocomplete}?input=$encodedInput',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is List) {
          return data
              .map(
                (item) => PlaceAutocompleteModel.fromJson(
                  item as Map<String, dynamic>,
                ),
              )
              .toList();
        } else if (data is Map) {
          List? list =
              (data['predictions'] ?? data['results'] ?? data['suggestions'])
                  as List?;

          // If not found at top level, check inside 'data' object
          if (list == null && data['data'] != null) {
            if (data['data'] is List) {
              list = data['data'] as List;
            } else if (data['data'] is Map) {
              final nestedData = data['data'] as Map<String, dynamic>;
              list =
                  (nestedData['predictions'] ??
                          nestedData['results'] ??
                          nestedData['suggestions'])
                      as List?;
            }
          }

          if (list != null) {
            return list
                .map(
                  (item) => PlaceAutocompleteModel.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();
          }
        }
        return [];
      } else {
        throw Exception('Failed to fetch autocomplete suggestions');
      }
    } catch (e) {
      throw Exception('Error fetching autocomplete suggestions: $e');
    }
  }

  /// Update an existing restaurant
  Future<void> updateRestaurant({
    required String id,
    required Map<String, dynamic> data,
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final fields = data.map((key, value) {
          if (value is List || value is Map) {
            return MapEntry(key, jsonEncode(value));
          }
          return MapEntry(key, value.toString());
        });

        final response = await _apiService.invokeMultipart(
          urlPath: '${ApiEndpoints.hotels}/$id',
          type: RequestType.patch,
          fields: fields,
          files: {'mainImage': imagePath},
          fun: (data) => jsonDecode(data),
        );

        if (response is! DataSuccess) {
          throw Exception('Failed to update restaurant');
        }
      } else {
        final response = await _apiService.invoke(
          urlPath: '${ApiEndpoints.hotels}/$id',
          type: RequestType.patch,
          params: data,
          fun: (data) => jsonDecode(data),
        );

        if (response is! DataSuccess) {
          throw Exception('Failed to update restaurant');
        }
      }
    } catch (e) {
      throw Exception('Error updating restaurant: $e');
    }
  }

  /// Build query string from parameters
  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '?$query';
  }
}
