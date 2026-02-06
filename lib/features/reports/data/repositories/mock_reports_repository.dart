import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/reports/domain/repositories/reports_repository_interface.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';

class MockReportsRepository implements ReportsRepositoryInterface {
  @override
  Future<List<ReportStats>> getReportStats() async {
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));

    return [
      const ReportStats(
        label: 'Revenue MTD',
        value: '₹4.8L',
        trend: 'up',
        percentage: '15%',
        compareLabel: 'vs yesterday',
      ),
      const ReportStats(
        label: 'Orders MTD',
        value: '2,456',
        trend:
            'neutral', // No trend shown in image for this one, or maybe icon missing
        percentage: '',
        compareLabel:
            'Orders MTD', // Image just says "Orders MTD" under the value too? No, "Orders MTD" is label. keeping simple.
      ),
      const ReportStats(
        label: 'Avg Order Value',
        value: '₹195',
        trend: 'up',
        percentage: '8%',
        compareLabel: 'vs yesterday',
      ),
      const ReportStats(
        label: 'Reports Generated',
        value: '12',
        trend: 'neutral',
        percentage: '',
        compareLabel: 'Reports Generated',
      ),
    ];
  }

  @override
  Future<List<ReportCategory>> getReportCategories() async {
    await Future.delayed(const Duration(milliseconds: 1000));

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
    await Future.delayed(const Duration(milliseconds: 900));

    return const [
      ChartDataPoint(date: 'Dec 7', value: 40000),
      ChartDataPoint(date: 'Dec 8', value: 45000),
      ChartDataPoint(date: 'Dec 9', value: 42000),
      ChartDataPoint(date: 'Dec 10', value: 48000),
      ChartDataPoint(date: 'Dec 11', value: 55000),
      ChartDataPoint(date: 'Dec 12', value: 52000),
      ChartDataPoint(date: 'Dec 13', value: 58000),
    ];
  }

  @override
  Future<List<RecentExport>> getRecentExports() async {
    await Future.delayed(const Duration(milliseconds: 700));

    return [
      RecentExport(
        filename: 'Daily_Sales_Dec12.pdf',
        date: 'Today',
        onDownload: () => debugPrint('Downloading Daily_Sales_Dec12.pdf'),
      ),
      RecentExport(
        filename: 'Weekly_Orders_W50.xlsx',
        date: 'Dec 9',
        onDownload: () => debugPrint('Downloading Weekly_Orders_W50.xlsx'),
      ),
      RecentExport(
        filename: 'Inventory_Nov.pdf',
        date: 'Dec 1',
        onDownload: () => debugPrint('Downloading Inventory_Nov.pdf'),
      ),
    ];
  }
}
