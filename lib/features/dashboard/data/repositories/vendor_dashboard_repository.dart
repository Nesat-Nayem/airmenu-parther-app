import 'dart:convert';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/constants/api_endpoints.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/logger/log.dart';

/// Repository interface for vendor dashboard data
abstract class VendorDashboardRepository {
  Future<VendorDashboardDataModel> getDashboardData({
    String dateRange = 'today',
    String? startDate,
    String? endDate,
    String? orderType,
    String? branch,
  });

  Future<VendorDashboardDataModel> refreshDashboardData();

  Future<OrdersOverTimeModel> getOrdersOverTimeData(String period);

  Future<List<CategoryPerformanceModel>> getCategoryPerformance(
    String period,
    String? hotelId,
  );

  Future<List<RecentOrderModel>> getRecentOrders(String? hotelId);

  Future<List<BranchModel>> getBranches();
}

/// Implementation with API calls
class VendorDashboardRepositoryImpl implements VendorDashboardRepository {
  final ApiService _apiService = locator<ApiService>();

  @override
  Future<VendorDashboardDataModel> getDashboardData({
    String dateRange = 'today',
    String? startDate,
    String? endDate,
    String? orderType, // 'All Types', 'Dine-in', etc.
    String? branch, // 'Main Branch', etc.
  }) async {
    // Determine period from dateRange or dates
    String period = dateRange.toLowerCase().replaceAll(' ', '-');
    if (period == 'this-week') period = 'week';
    if (period == 'this-month') period = 'month';

    // Map order type to API value
    String? typeParam;
    if (orderType != null && orderType != 'All Types') {
      typeParam = orderType.toLowerCase();
    }

    try {
      // Build query parameters
      final params = <String, String>{'period': period};
      if (typeParam != null) params['type'] = typeParam;
      if (branch != null) params['hotelId'] = branch;

      // 1. Fetch Dashboard Stats (Critical)
      DashboardStatsResponse? dashboardStats;
      try {
        final response = await _apiService.invoke<DashboardStatsResponse>(
          urlPath:
              ApiEndpoints.vendorDashboardStats + _buildQueryString(params),
          type: RequestType.get,
          fun: (data) => DashboardStatsResponse.fromJson(
            Map<String, dynamic>.from(jsonDecode(data)['data']),
          ),
        );
        if (response is DataSuccess) {
          dashboardStats = response.data;
        } else if (response is DataFailure) {
          Log.error('Dashboard Stats API failed: ${response.error?.message}');
        }
      } catch (e) {
        Log.error('Error fetching dashboard stats: $e');
        // Continue execution even if main stats fail, so we can try fetching charts/tables
      }

      // 2. Fetch Order Stats
      OrderStatsResponse? orderStats;
      try {
        final response = await _apiService.invoke<OrderStatsResponse>(
          urlPath: ApiEndpoints.orderStats + _buildQueryString(params),
          type: RequestType.get,
          fun: (data) => OrderStatsResponse.fromJson(
            Map<String, dynamic>.from(jsonDecode(data)['data']),
          ),
        );
        if (response is DataSuccess) {
          orderStats = response.data;
        } else if (response is DataFailure) {
          Log.warning('Order Stats API failed: ${response.error?.message}');
        }
      } catch (e) {
        Log.warning('Failed to fetch order-stats: $e');
      }

      // 3. Fetch Orders Over Time (Chart)
      OrdersOverTimeModel? ordersOverTime;
      try {
        ordersOverTime = await getOrdersOverTimeData(period);
      } catch (e) {
        Log.warning('Failed to fetch orders over time: $e');
      }

      // 4. Fetch Category Performance
      List<CategoryPerformanceModel>? categoryPerformance;
      try {
        categoryPerformance = await getCategoryPerformance(period, branch);
      } catch (e) {
        Log.warning('Failed to fetch category performance: $e');
      }

      // 5. Fetch Recent Orders
      List<RecentOrderModel>? recentOrders;
      try {
        recentOrders = await getRecentOrders(branch);
      } catch (e) {
        Log.warning('Failed to fetch recent orders: $e');
      }

      // Use empty/default objects if fetch failed
      return _mapApiDataToModel(
        dashboardStats ??
            DashboardStatsResponse(
              totalOrders: 0,
              totalOrdersChange: 0,
              totalOrdersIsPositive: true,
              totalRevenue: 0,
              revenueChange: 0,
              revenueIsPositive: true,
              dineInOrders: 0,
              dineInChange: 0,
              dineInIsPositive: true,
              takeawayOrders: 0,
              takeawayChange: 0,
              takeawayIsPositive: true,
              avgPrepTime: '0min',
              avgPrepTimeChange: 0,
              avgPrepTimeIsPositive: true,
              kitchenLoad: 0,
              kitchenLoadChange: 0,
              kitchenLoadIsPositive: false,
              inventoryAlerts: 0,
              inventoryAlertMessage: '',
              topMenuItems: [],
            ),
        orderStats ??
            OrderStatsResponse(
              pending: OrderStatItem(value: 0),
              inKitchen: OrderStatItem(value: 0),
              ready: OrderStatItem(value: 0),
              delayed: OrderStatItem(value: 0),
            ),
        ordersOverTime ??
            OrdersOverTimeModel(labels: [], orderCounts: [], period: period),
        categoryPerformance ?? [],
        recentOrders ?? [],
        period,
      );
    } catch (e) {
      Log.error('Error fetching dashboard data: $e');
      return VendorDashboardDataModel.empty();
    }
  }

  @override
  Future<VendorDashboardDataModel> refreshDashboardData() async {
    return getDashboardData();
  }

  @override
  Future<OrdersOverTimeModel> getOrdersOverTimeData(String period) async {
    try {
      final params = <String, String>{'period': period};
      // Add other params if needed from some state source, but for now just period

      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.vendorOrdersOverTime + _buildQueryString(params),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          return OrdersOverTimeModel.fromJson(data['data']);
        }
      }
      return OrdersOverTimeModel(labels: [], orderCounts: [], period: period);
    } catch (e) {
      Log.error('Error fetching orders over time: $e');
      return OrdersOverTimeModel(labels: [], orderCounts: [], period: period);
    }
  }

  @override
  Future<List<CategoryPerformanceModel>> getCategoryPerformance(
    String period,
    String? hotelId,
  ) async {
    try {
      final params = <String, String>{'period': period};
      if (hotelId != null) params['hotelId'] = hotelId;

      final response = await _apiService.invoke(
        urlPath:
            ApiEndpoints.vendorCategoryPerformance + _buildQueryString(params),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final list = data['data'] as List?;
          return list
                  ?.map((e) => CategoryPerformanceModel.fromJson(e))
                  .toList() ??
              [];
        }
      }
      return [];
    } catch (e) {
      Log.error('Error fetching category performance: $e');
      return [];
    }
  }

  @override
  Future<List<RecentOrderModel>> getRecentOrders(String? hotelId) async {
    try {
      final params = <String, String>{'limit': '10'};
      if (hotelId != null) params['hotelId'] = hotelId;

      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.vendorRecentOrders + _buildQueryString(params),
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['success'] == true) {
          final list = data['data'] as List?;
          return list?.map((e) => RecentOrderModel.fromJson(e)).toList() ?? [];
        }
      }
      return [];
    } catch (e) {
      Log.error('Error fetching recent orders: $e');
      return [];
    }
  }

  @override
  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _apiService.invoke(
        urlPath: ApiEndpoints.vendorBranches,
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['data'] is List) {
          return (data['data'] as List)
              .map((e) => BranchModel.fromJson(e))
              .toList();
        } else if (data is List) {
          return data.map((e) => BranchModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      Log.error('Error fetching branches: $e');
      return [];
    }
  }

  /// Build query string from parameters
  String _buildQueryString(Map<String, String> params) {
    if (params.isEmpty) return '';
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return '?$query';
  }

  VendorDashboardDataModel _mapApiDataToModel(
    DashboardStatsResponse dashboardStats,
    OrderStatsResponse orderStats,
    OrdersOverTimeModel ordersOverTime,
    List<CategoryPerformanceModel> categoryPerformance,
    List<RecentOrderModel> recentOrders,
    String period,
  ) {
    return VendorDashboardDataModel(
      stats: VendorStatsModel(
        totalOrdersToday: dashboardStats.totalOrders,
        totalOrdersChange: dashboardStats.totalOrdersChange,
        totalOrdersIsPositive: dashboardStats.totalOrdersIsPositive,
        dineInOrders: dashboardStats.dineInOrders,
        dineInChange: dashboardStats.dineInChange,
        dineInIsPositive: dashboardStats.dineInIsPositive,
        takeawayOrders: dashboardStats.takeawayOrders,
        takeawayChange: dashboardStats.takeawayChange,
        takeawayIsPositive: dashboardStats.takeawayIsPositive,
        avgPrepTime: dashboardStats.avgPrepTime,
        avgPrepTimeChange: dashboardStats.avgPrepTimeChange,
        avgPrepTimeIsPositive: dashboardStats.avgPrepTimeIsPositive,
        kitchenLoad: dashboardStats.kitchenLoad,
        kitchenLoadChange: dashboardStats.kitchenLoadChange,
        kitchenLoadIsPositive: dashboardStats.kitchenLoadIsPositive,
        inventoryAlerts: dashboardStats.inventoryAlerts,
        inventoryAlertMessage: dashboardStats.inventoryAlertMessage,
      ),
      ordersOverTime: ordersOverTime,
      categoryPerformance: categoryPerformance,
      orderTypeBreakdown: OrderTypeBreakdownModel(
        dineInCount: dashboardStats.dineInOrders,
        takeawayCount: dashboardStats.takeawayOrders,
        deliveryCount: 0, // Delivery not explicitly in stats yet, defaulting 0
      ),
      bestsellingItems: dashboardStats.topMenuItems.asMap().entries.map((
        entry,
      ) {
        final item = entry.value;
        final index = entry.key;
        return BestsellingItemModel(
          rank: index + 1,
          itemName: item.title,
          unitsSold: item.totalOrders,
          revenue: item.totalRevenue,
          revenueChange: 0,
          revenueChangeIsPositive: true,
        );
      }).toList(),
      recentOrders: recentOrders,
    );
  }
}
