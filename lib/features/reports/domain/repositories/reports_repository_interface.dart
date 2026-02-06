import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';

abstract class ReportsRepositoryInterface {
  Future<List<ReportStats>> getReportStats();
  Future<List<ReportCategory>> getReportCategories();
  Future<List<ChartDataPoint>> getChartData();
  Future<List<RecentExport>> getRecentExports();
}
