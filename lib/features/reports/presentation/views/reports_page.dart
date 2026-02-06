import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:airmenuai_partner_app/features/reports/data/repositories/mock_reports_repository.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/bloc/reports_event.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/bloc/reports_state.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_category_card.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/report_stats_card.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/reports_shimmer.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/quick_overview_chart.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/widgets/recent_exports_list.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/sales_report_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/order_analytics_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/inventory_report_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/staff_performance_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/gst_report_page.dart';
import 'package:airmenuai_partner_app/features/reports/presentation/views/category_analysis_page.dart';
import 'package:airmenuai_partner_app/features/reports/data/models/report_category_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ReportsBloc(repository: MockReportsRepository())
            ..add(LoadReportsData()),
      child: const _ReportsView(),
    );
  }
}

class _ReportsView extends StatelessWidget {
  const _ReportsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const ReportsShimmer();
          }

          if (state.error != null) {
            return Center(child: Text('Error: ${state.error}'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isMobile = constraints.maxWidth < 900;
              final padding = isMobile ? 16.0 : 32.0;

              return SingleChildScrollView(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER SECTION
                    Row(
                      children: [
                        Text(
                          'Reports',
                          style: AirMenuTextStyle.headingH3.bold700().withColor(
                            Colors.grey.shade900,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('✨', style: TextStyle(fontSize: 20)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sales and performance analytics',
                      style: AirMenuTextStyle.small.withColor(
                        Colors.grey.shade500,
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Stats Row
                    _buildStatsRow(state, isMobile),
                    const SizedBox(height: 32),

                    // Categories Grid with navigation
                    _buildCategoriesGrid(context, state, isMobile, constraints),
                    const SizedBox(height: 32),

                    // Bottom Section: Chart + Recent Exports
                    _buildBottomSection(state, isMobile),
                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatsRow(ReportsState state, bool isMobile) {
    if (state.stats.isEmpty) {
      return const SizedBox.shrink();
    }

    if (isMobile) {
      return Column(
        children: state.stats
            .map(
              (stat) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ReportStatsCard(stat: stat),
              ),
            )
            .toList(),
      );
    }

    // Desktop: Use Row without IntrinsicHeight - let cards size themselves
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: state.stats.asMap().entries.map((entry) {
        final index = entry.key;
        final stat = entry.value;
        final isLast = index == state.stats.length - 1;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 16),
            child: ReportStatsCard(stat: stat),
          ),
        );
      }).toList(),
    ).animate().fadeIn().slideY(begin: 0.2, end: 0);
  }

  Widget _buildCategoriesGrid(
    BuildContext context,
    ReportsState state,
    bool isMobile,
    BoxConstraints constraints,
  ) {
    // Build categories with navigation callbacks
    final categoriesWithNav = _buildCategoriesWithNavigation(context, state);

    final crossAxisCount = isMobile ? 1 : 3;
    final spacing = 16.0;
    final itemWidth =
        (constraints.maxWidth -
            (crossAxisCount - 1) * spacing -
            (isMobile ? 32 : 64)) /
        crossAxisCount;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: categoriesWithNav.asMap().entries.map((entry) {
        final index = entry.key;
        final category = entry.value;
        return SizedBox(
          width: isMobile ? double.infinity : itemWidth,
          child: ReportCategoryCard(category: category)
              .animate(delay: (100 * index).ms)
              .fadeIn()
              .slideY(begin: 0.1, end: 0),
        );
      }).toList(),
    );
  }

  List<ReportCategory> _buildCategoriesWithNavigation(
    BuildContext context,
    ReportsState state,
  ) {
    // Map original categories to include navigation callbacks
    return state.categories.map((category) {
      VoidCallback onTap;

      switch (category.title) {
        case 'Sales Report':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SalesReportPage()),
          );
          break;
        case 'Order Analytics':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const OrderAnalyticsPage()),
          );
          break;
        case 'Inventory Report':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InventoryReportPage()),
          );
          break;
        case 'Staff Performance':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const StaffPerformancePage()),
          );
          break;
        case 'GST Report':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const GstReportPage()),
          );
          break;
        case 'Category Analysis':
          onTap = () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CategoryAnalysisPage()),
          );
          break;
        default:
          onTap = () => debugPrint('Navigate to ${category.title}');
      }

      return ReportCategory(
        title: category.title,
        subtitle: category.subtitle,
        icon: category.icon,
        iconColor: category.iconColor,
        iconBackgroundColor: category.iconBackgroundColor,
        onTap: onTap,
      );
    }).toList();
  }

  Widget _buildBottomSection(ReportsState state, bool isMobile) {
    if (isMobile) {
      return Column(
        children: [
          QuickOverviewChart(data: state.chartData),
          const SizedBox(height: 24),
          RecentExportsList(
            exports: state.recentExports,
            onViewAll: () => debugPrint('View All Exports'),
          ),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 3, child: QuickOverviewChart(data: state.chartData)),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: RecentExportsList(
            exports: state.recentExports,
            onViewAll: () => debugPrint('View All Exports'),
          ),
        ),
      ],
    );
  }
}
