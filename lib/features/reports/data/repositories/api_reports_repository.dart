import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/core/network/data_state.dart';
import 'package:airmenuai_partner_app/core/network/request_type.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/utils/shared_preferences/local_storage.dart';
import 'package:airmenuai_partner_app/features/reports/domain/repositories/reports_repository_interface.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';

class ApiReportsRepository implements ReportsRepositoryInterface {
  final ApiService _apiService = locator<ApiService>();
  final LocalStorage _localStorage = locator<LocalStorage>();

  Future<String?> _getHotelId() async {
    return await _localStorage.getString(localStorageKey: 'hotelId');
  }

  /// Fetch report stats from backend API
  Future<Map<String, dynamic>> fetchReportStatsRaw() async {
    try {
      final hotelId = await _getHotelId();
      final queryParams = hotelId != null ? '?hotelId=$hotelId' : '';

      final response = await _apiService.invoke(
        urlPath: '/reports/stats$queryParams',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {};
    } catch (e) {
      debugPrint('Error fetching report stats: $e');
      return {};
    }
  }

  /// Fetch orders from backend API
  Future<Map<String, dynamic>> fetchOrdersRaw({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final hotelId = await _getHotelId();
      final params = <String, String>{};
      if (hotelId != null) params['hotelId'] = hotelId;
      params['page'] = page.toString();
      params['limit'] = limit.toString();
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (paymentStatus != null && paymentStatus.isNotEmpty) params['paymentStatus'] = paymentStatus;
      if (startDate != null && startDate.isNotEmpty) params['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) params['endDate'] = endDate;

      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await _apiService.invoke(
        urlPath: '/reports/orders?$queryString',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {'orders': [], 'total': 0, 'totalPages': 0};
    } catch (e) {
      debugPrint('Error fetching orders: $e');
      return {'orders': [], 'total': 0, 'totalPages': 0};
    }
  }

  /// Fetch bookings from backend API
  Future<Map<String, dynamic>> fetchBookingsRaw({
    int page = 1,
    int limit = 10,
    String? status,
    String? paymentStatus,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final hotelId = await _getHotelId();
      final params = <String, String>{};
      if (hotelId != null) params['hotelId'] = hotelId;
      params['page'] = page.toString();
      params['limit'] = limit.toString();
      if (status != null && status.isNotEmpty) params['status'] = status;
      if (paymentStatus != null && paymentStatus.isNotEmpty) params['paymentStatus'] = paymentStatus;
      if (startDate != null && startDate.isNotEmpty) params['startDate'] = startDate;
      if (endDate != null && endDate.isNotEmpty) params['endDate'] = endDate;

      final queryString = params.entries.map((e) => '${e.key}=${e.value}').join('&');

      final response = await _apiService.invoke(
        urlPath: '/reports/bookings?$queryString',
        type: RequestType.get,
        fun: (data) => jsonDecode(data),
      );

      if (response is DataSuccess && response.data != null) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }
      }
      return {'bookings': [], 'total': 0, 'totalPages': 0};
    } catch (e) {
      debugPrint('Error fetching bookings: $e');
      return {'bookings': [], 'total': 0, 'totalPages': 0};
    }
  }

  @override
  Future<List<ReportStats>> getReportStats() async {
    final raw = await fetchReportStatsRaw();
    if (raw.isEmpty) {
      return [
        const ReportStats(label: 'Revenue MTD', value: '₹0', trend: 'neutral', percentage: '', compareLabel: ''),
        const ReportStats(label: 'Orders MTD', value: '0', trend: 'neutral', percentage: '', compareLabel: ''),
        const ReportStats(label: 'Avg Order Value', value: '₹0', trend: 'neutral', percentage: '', compareLabel: ''),
        const ReportStats(label: 'Bookings', value: '0', trend: 'neutral', percentage: '', compareLabel: ''),
      ];
    }

    final totalOrders = raw['totalOrders'] ?? 0;
    final totalBookings = raw['totalBookings'] ?? 0;
    final totalRevenue = (raw['totalRevenue'] as num?)?.toDouble() ?? 0;
    final todayOrders = raw['todayOrders'] ?? 0;
    final todayBookings = raw['todayBookings'] ?? 0;
    final pendingOrders = raw['pendingOrders'] ?? 0;
    final avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0.0;

    return [
      ReportStats(
        label: 'Revenue MTD',
        value: _formatCurrency(totalRevenue),
        trend: 'up',
        percentage: '+${todayOrders} today',
        compareLabel: 'Total revenue',
      ),
      ReportStats(
        label: 'Orders MTD',
        value: _formatNumber(totalOrders),
        trend: pendingOrders > 0 ? 'up' : 'neutral',
        percentage: '$pendingOrders pending',
        compareLabel: 'Total orders',
      ),
      ReportStats(
        label: 'Avg Order Value',
        value: _formatCurrency(avgOrderValue),
        trend: 'up',
        percentage: '',
        compareLabel: 'Per order',
      ),
      ReportStats(
        label: 'Bookings',
        value: _formatNumber(totalBookings),
        trend: todayBookings > 0 ? 'up' : 'neutral',
        percentage: '+${todayBookings} today',
        compareLabel: 'Table bookings',
      ),
    ];
  }

  @override
  Future<List<ReportCategory>> getReportCategories() async {
    // Categories are static navigation items - they don't come from API
    return [
      ReportCategory(
        title: 'Sales Report',
        subtitle: 'Daily, weekly, and monthly sales analysis',
        icon: Icons.trending_up,
        iconColor: const Color(0xFF10B981),
        iconBackgroundColor: const Color(0xFFD1FAE5),
        onTap: () {},
      ),
      ReportCategory(
        title: 'Order Analytics',
        subtitle: 'Order volumes, types, and trends',
        icon: Icons.shopping_bag_outlined,
        iconColor: const Color(0xFFEF4444),
        iconBackgroundColor: const Color(0xFFFEE2E2),
        onTap: () {},
      ),
      ReportCategory(
        title: 'Inventory Report',
        subtitle: 'Stock usage, wastage, and alerts',
        icon: Icons.inventory_2_outlined,
        iconColor: const Color(0xFFF59E0B),
        iconBackgroundColor: const Color(0xFFFEF3C7),
        onTap: () {},
      ),
      ReportCategory(
        title: 'Staff Performance',
        subtitle: 'Orders handled and service metrics',
        icon: Icons.people_outline,
        iconColor: const Color(0xFF3B82F6),
        iconBackgroundColor: const Color(0xFFDBEAFE),
        onTap: () {},
      ),
      ReportCategory(
        title: 'GST Report',
        subtitle: 'Tax summaries and invoices',
        icon: Icons.credit_card,
        iconColor: const Color(0xFF8B5CF6),
        iconBackgroundColor: const Color(0xFFEDE9FE),
        onTap: () {},
      ),
      ReportCategory(
        title: 'Category Analysis',
        subtitle: 'Performance by menu category',
        icon: Icons.bar_chart_rounded,
        iconColor: const Color(0xFFF97316),
        iconBackgroundColor: const Color(0xFFFFEDD5),
        onTap: () {},
      ),
    ];
  }

  @override
  Future<List<ChartDataPoint>> getChartData() async {
    // Fetch last 7 days of orders to build chart data
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 6));

      final ordersData = await fetchOrdersRaw(
        page: 1,
        limit: 1000,
        startDate: sevenDaysAgo.toIso8601String().split('T')[0],
        endDate: now.toIso8601String().split('T')[0],
      );

      final List<dynamic> orders = ordersData['orders'] ?? [];

      // Group by day
      final Map<String, double> dailyRevenue = {};
      for (int i = 0; i < 7; i++) {
        final date = sevenDaysAgo.add(Duration(days: i));
        final key = '${_monthName(date.month)} ${date.day}';
        dailyRevenue[key] = 0;
      }

      for (final order in orders) {
        final createdAt = order['createdAt'];
        if (createdAt != null) {
          final date = DateTime.tryParse(createdAt.toString());
          if (date != null) {
            final key = '${_monthName(date.month)} ${date.day}';
            final amount = (order['totalAmount'] as num?)?.toDouble() ?? 0;
            dailyRevenue[key] = (dailyRevenue[key] ?? 0) + amount;
          }
        }
      }

      return dailyRevenue.entries
          .map((e) => ChartDataPoint(date: e.key, value: e.value))
          .toList();
    } catch (e) {
      debugPrint('Error fetching chart data: $e');
      return [];
    }
  }

  @override
  Future<List<RecentExport>> getRecentExports() async {
    // Recent exports are local items, not from API
    return [
      RecentExport(
        filename: 'No exports yet',
        date: '',
        onDownload: () {},
      ),
    ];
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    } else if (amount >= 1000) {
      return '₹${(amount / 1000).toStringAsFixed(1)}K';
    }
    return '₹${amount.toStringAsFixed(0)}';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}
