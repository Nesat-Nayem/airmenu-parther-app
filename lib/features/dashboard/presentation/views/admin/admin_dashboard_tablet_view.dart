import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_event.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_state.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_stat_card.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/high_risk_alerts_banner.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/orders_by_type_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_date_filter.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_category_filter.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_search_field.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/kitchen_load_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/restaurant_performance_table.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/rider_sla_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/live_activity_widget.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/top_restaurants_table.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_skeleton_loader.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class AdminDashboardTabletView extends StatelessWidget {
  const AdminDashboardTabletView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDashboardBloc(
        repository: AdminDashboardRepository(locator<ApiService>()),
      )..add(const LoadAdminDashboardData()),
      child: const _AdminDashboardTabletContent(),
    );
  }
}

class _AdminDashboardTabletContent extends StatelessWidget {
  const _AdminDashboardTabletContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return _buildTabletSkeleton();
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AirMenuColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard',
                  style: AirMenuTextStyle.subheadingH5,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => context.read<AdminDashboardBloc>().add(
                    const LoadAdminDashboardData(),
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is AdminDashboardLoaded ||
            state is AdminDashboardRefreshing) {
          final data = state is AdminDashboardLoaded
              ? state.data
              : (state as AdminDashboardRefreshing).currentData;
          final currentView = state is AdminDashboardLoaded
              ? state.currentView
              : 'today';

          return RefreshIndicator(
            onRefresh: () async => context.read<AdminDashboardBloc>().add(
              const RefreshAdminDashboardData(),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search field
                  DashboardSearchField(
                    onSearchChanged: (query) {
                      context.read<AdminDashboardBloc>().add(
                        SearchDashboard(query),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  // Filters
                  Align(
                    alignment: Alignment.topRight,
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,

                      children: [
                        DashboardDateFilter(
                          selectedRange: state is AdminDashboardLoaded
                              ? state.dateRange
                              : 'today',
                          onRangeChanged: (range) {
                            String dateRange = range;
                            if (range == '30 day') dateRange = '30days';
                            if (range == '90 days') dateRange = '90days';
                            context.read<AdminDashboardBloc>().add(
                              FilterByDateRange(dateRange: dateRange),
                            );
                          },
                        ),
                        DashboardCategoryFilter(
                          selectedCategory: state is AdminDashboardLoaded
                              ? (state.selectedCategory ?? 'all')
                              : 'all',
                          onCategoryChanged: (category) {
                            context.read<AdminDashboardBloc>().add(
                              FilterByCategory(category),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Stat cards grid (3 columns) - Responsive internal sizing
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          1.25, // Balanced ratio with responsive internal sizing
                    ),
                    itemCount: data.stats.toStatCards().length,
                    itemBuilder: (context, index) => DashboardStatCard(
                      stat: data.stats.toStatCards()[index],
                      index: index,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Alerts
                  // High-risk alerts banner
                  if (data.alerts.isNotEmpty)
                    HighRiskAlertsBanner(
                      alerts: data.alerts,
                      onViewAll: () {
                        // Show snackbar until dedicated alerts page is implemented
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${data.alerts.length} alerts available. Detailed alerts page coming soon!',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  if (data.alerts.isNotEmpty) const SizedBox(height: 24),

                  // Charts (stacked)
                  SizedBox(
                    height: 360,
                    child: OrdersByTypeChart(
                      data: data.ordersByType,
                      currentView: currentView,
                      onViewChanged: (view) =>
                          context.read<AdminDashboardBloc>().add(
                            UpdateAdminChartView(
                              chartType: 'orders-by-type',
                              period: view,
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 360,
                    child: KitchenLoadChart(data: data.kitchenLoad),
                  ),
                  const SizedBox(height: 20),

                  // Tables (stacked)
                  SizedBox(
                    height: 420,
                    child: RestaurantPerformanceTable(
                      restaurants: data.restaurantPerformance,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 420,
                    child: RiderSLAChart(riders: data.riderSLA),
                  ),
                  const SizedBox(height: 20),

                  // Bottom section (stacked)
                  SizedBox(
                    height: 460,
                    child: LiveActivityWidget(
                      activities: data.liveActivities,
                      onRefresh: () => context.read<AdminDashboardBloc>().add(
                        const RefreshAdminDashboardData(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 460,
                    child: TopRestaurantsTable(
                      restaurants: data.topRestaurants,
                    ),
                  ),
                  const SizedBox(height: 20), // Bottom padding
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTabletSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search and filters skeleton
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 120,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 150,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Stat cards grid (3 columns)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.25,
            ),
            itemCount: 6,
            itemBuilder: (context, index) => DashboardSkeletonLoader.statCard(),
          ),
          const SizedBox(height: 20),

          // Charts (stacked)
          DashboardSkeletonLoader.chartCard(height: 360),
          const SizedBox(height: 16),
          DashboardSkeletonLoader.chartCard(height: 360),
          const SizedBox(height: 20),

          // Tables (stacked)
          DashboardSkeletonLoader.tableCard(height: 420),
          const SizedBox(height: 16),
          DashboardSkeletonLoader.tableCard(height: 420),
          const SizedBox(height: 20),

          // Bottom section (stacked)
          DashboardSkeletonLoader.listCard(height: 460),
          const SizedBox(height: 16),
          DashboardSkeletonLoader.listCard(height: 460),
        ],
      ),
    );
  }
}
