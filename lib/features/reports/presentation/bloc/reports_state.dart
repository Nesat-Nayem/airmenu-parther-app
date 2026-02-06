import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';

class ReportsState {
  final List<ReportStats> stats;
  final List<ReportCategory> categories;
  final List<ChartDataPoint> chartData;
  final List<RecentExport> recentExports;
  final bool isLoading;
  final String? error;

  const ReportsState({
    this.stats = const [],
    this.categories = const [],
    this.chartData = const [],
    this.recentExports = const [],
    this.isLoading = false,
    this.error,
  });

  ReportsState copyWith({
    List<ReportStats>? stats,
    List<ReportCategory>? categories,
    List<ChartDataPoint>? chartData,
    List<RecentExport>? recentExports,
    bool? isLoading,
    String? error,
  }) {
    return ReportsState(
      stats: stats ?? this.stats,
      categories: categories ?? this.categories,
      chartData: chartData ?? this.chartData,
      recentExports: recentExports ?? this.recentExports,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
