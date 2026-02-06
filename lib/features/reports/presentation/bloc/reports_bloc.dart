import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_stats_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/chart_data_point_model.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/recent_export_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/reports/domain/repositories/reports_repository_interface.dart';

import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportsRepositoryInterface repository;

  ReportsBloc({required this.repository}) : super(const ReportsState()) {
    on<LoadReportsData>(_onLoadReportsData);
  }

  Future<void> _onLoadReportsData(
    LoadReportsData event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final results = await Future.wait([
        repository.getReportStats(),
        repository.getReportCategories(),
        repository.getChartData(),
        repository.getRecentExports(),
      ]);

      emit(
        state.copyWith(
          isLoading: false,
          stats: results[0] as List<ReportStats>,
          categories: results[1] as List<ReportCategory>,
          chartData: results[2] as List<ChartDataPoint>,
          recentExports: results[3] as List<RecentExport>,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
