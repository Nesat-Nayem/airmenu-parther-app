import 'dart:convert';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import '../../data/models/shared/dashboard_models.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';

/// Repository for admin dashboard data - uses real API calls
class AdminDashboardRepository {
  final ApiService _apiService;

  AdminDashboardRepository(this._apiService);

  /// Get main dashboard data with date range filter
  Future<DashboardDataModel> getDashboardData({
    String dateRange = 'today',
    String? startDate,
    String? endDate,
  }) async {
    try {
      // Build query parameters
      final queryParams = <String, String>{'dateRange': dateRange};
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;

      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.adminDashboard + _buildQueryString(queryParams),
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as Map<String, dynamic>;

        // Parse platform stats
        final stats = DashboardStatsModel.fromJson(
          data['platformStats'] as Map<String, dynamic>? ?? {},
        );

        // Parse alerts
        final alertsList =
            (data['alerts'] as List?)?.map((e) {
              return HighRiskAlertModel.fromJson(e as Map<String, dynamic>);
            }).toList() ??
            [];

        // Parse live activities
        final activitiesList =
            (data['liveActivities'] as List?)?.map((e) {
              return LiveActivityModel.fromJson(e as Map<String, dynamic>);
            }).toList() ??
            [];

        // Parse top restaurants
        final topRestaurantsList =
            (data['topRestaurants'] as List?)?.map((e) {
              return TopRestaurantModel.fromJson(e as Map<String, dynamic>);
            }).toList() ??
            [];

        return DashboardDataModel(
          stats: stats,
          alerts: alertsList,
          liveActivities: activitiesList,
          topRestaurants: topRestaurantsList,
          restaurantPerformance: [],
          riderSLA: [],
        );
      } else {
        throw Exception('Failed to load dashboard data');
      }
    } catch (e) {
      throw Exception('Error fetching dashboard data: $e');
    }
  }

  /// Get top restaurants with sorting
  Future<List<TopRestaurantModel>> getTopRestaurants({
    String sortBy = 'orders',
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, String>{
        'sortBy': sortBy,
        'limit': limit.toString(),
      };

      final response = await _apiService.invoke(
        urlPath:
            ApiEndpoints.adminTopRestaurants + _buildQueryString(queryParams),
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as List;
        return data
            .map((e) => TopRestaurantModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching top restaurants: $e');
    }
  }

  /// Get orders by type chart data
  Future<OrdersByTypeChartModel> getOrdersByType({
    String period = 'today',
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.adminOrdersByType}?period=$period',
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as Map<String, dynamic>;
        return OrdersByTypeChartModel.fromJson(data);
      } else {
        throw Exception('Failed to load orders by type');
      }
    } catch (e) {
      throw Exception('Error fetching orders by type: $e');
    }
  }

  /// Get kitchen load chart data
  Future<KitchenLoadChartModel> getKitchenLoad({
    String period = 'today',
  }) async {
    try {
      final response = await _apiService.invoke(
        urlPath: '${ApiEndpoints.adminKitchenLoad}?period=$period',
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as Map<String, dynamic>;
        return KitchenLoadChartModel.fromJson(data);
      } else {
        throw Exception('Failed to load kitchen load');
      }
    } catch (e) {
      throw Exception('Error fetching kitchen load: $e');
    }
  }

  /// Get restaurant performance data
  Future<List<RestaurantPerformanceModel>> getRestaurantPerformance() async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.adminRestaurantPerformance,
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as List;
        return data
            .map(
              (e) => RestaurantPerformanceModel.fromJson(
                e as Map<String, dynamic>,
              ),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching restaurant performance: $e');
    }
  }

  /// Get rider SLA data
  Future<List<RiderSLAModel>> getRiderSLA() async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.adminRiderSLA,
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as List;
        return data
            .map((e) => RiderSLAModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching rider SLA: $e');
    }
  }

  /// Get alerts with filters
  Future<List<HighRiskAlertModel>> getAlerts({
    String? severity,
    String? status,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (severity != null) queryParams['severity'] = severity;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.adminAlerts + _buildQueryString(queryParams),
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as Map<String, dynamic>;
        final alertsList = data['alerts'] as List;
        return alertsList
            .map((e) => HighRiskAlertModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// Get live activities with filters
  Future<List<LiveActivityModel>> getActivities({
    int limit = 20,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{'limit': limit.toString()};
      if (type != null) queryParams['type'] = type;

      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.adminActivities + _buildQueryString(queryParams),
        type: RequestType.get,
        fun: (responseBody) => responseBody,
      );

      if (response is DataSuccess<String>) {
        final json = jsonDecode(response.data!);
        final data = json['data'] as List;
        return data
            .map((e) => LiveActivityModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Error fetching activities: $e');
    }
  }

  /// Build query string from parameters
  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '?$query';
  }
}
