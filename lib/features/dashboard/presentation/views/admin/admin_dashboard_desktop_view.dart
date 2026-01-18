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
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/kitchen_load_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/restaurant_performance_table.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/rider_sla_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/live_activity_widget.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/admin/top_restaurants_table.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_skeleton_loader.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/core/network/api_service.dart';
import 'package:airmenuai_partner_app/utils/injectible.dart';

class AdminDashboardDesktopView extends StatelessWidget {
  const AdminDashboardDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AdminDashboardBloc(
        repository: AdminDashboardRepository(locator<ApiService>()),
      )..add(const LoadAdminDashboardData()),
      child: const _AdminDashboardDesktopContent(),
    );
  }
}

class _AdminDashboardDesktopContent extends StatelessWidget {
  const _AdminDashboardDesktopContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminDashboardBloc, AdminDashboardState>(
      builder: (context, state) {
        if (state is AdminDashboardLoading) {
          return _buildDesktopSkeleton();
        }

        if (state is AdminDashboardError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AirMenuColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading dashboard',
                  style: AirMenuTextStyle.subheadingH5,
                ),
                const SizedBox(height: 8),
                Text(
                  state.message,
                  style: AirMenuTextStyle.normal.copyWith(
                    color: const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<AdminDashboardBloc>().add(
                      const LoadAdminDashboardData(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AirMenuColors.primary,
                    foregroundColor: Colors.white,
                  ),
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
            onRefresh: () async {
              context.read<AdminDashboardBloc>().add(
                const RefreshAdminDashboardData(),
              );
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 300,
                            child: DashboardSearchField(
                              onSearchChanged: (query) {
                                context.read<AdminDashboardBloc>().add(
                                  SearchDashboard(query),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
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
                          const SizedBox(width: 12),
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
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stat cards grid (4x2)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.8,
                        ),
                    itemCount: data.stats.toStatCards().length,
                    itemBuilder: (context, index) {
                      final statCards = data.stats.toStatCards();
                      return DashboardStatCard(
                        stat: statCards[index],
                        index: index,
                      );
                    },
                  ),
                  const SizedBox(height: 24),

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

                  // Charts row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 400,
                          child: OrdersByTypeChart(
                            data: data.ordersByType,
                            currentView: currentView,
                            onViewChanged: (view) {
                              context.read<AdminDashboardBloc>().add(
                                UpdateAdminChartView(
                                  chartType: 'orders-by-type',
                                  period: view,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 400,
                          child: KitchenLoadChart(data: data.kitchenLoad),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Tables row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 450,
                          child: RestaurantPerformanceTable(
                            restaurants: data.restaurantPerformance,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 450,
                          child: RiderSLAChart(riders: data.riderSLA),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Bottom row: Live Activity and Top Restaurants
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 500,
                          child: LiveActivityWidget(
                            activities: data.liveActivities,
                            onRefresh: () {
                              context.read<AdminDashboardBloc>().add(
                                const RefreshAdminDashboardData(),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 500,
                          child: TopRestaurantsTable(
                            restaurants: data.topRestaurants,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildDesktopSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 250,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 180,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    width: 300,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
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
            ],
          ),
          const SizedBox(height: 24),

          // Stat cards grid (4x2)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: 8,
            itemBuilder: (context, index) => DashboardSkeletonLoader.statCard(),
          ),
          const SizedBox(height: 24),

          // Charts row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DashboardSkeletonLoader.chartCard(height: 400)),
              const SizedBox(width: 16),
              Expanded(child: DashboardSkeletonLoader.chartCard(height: 400)),
            ],
          ),
          const SizedBox(height: 24),

          // Tables row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DashboardSkeletonLoader.tableCard(height: 450)),
              const SizedBox(width: 16),
              Expanded(child: DashboardSkeletonLoader.tableCard(height: 450)),
            ],
          ),
          const SizedBox(height: 24),

          // Bottom row: Live Activity and Top Restaurants
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: DashboardSkeletonLoader.listCard(height: 500)),
              const SizedBox(width: 16),
              Expanded(child: DashboardSkeletonLoader.listCard(height: 500)),
            ],
          ),
        ],
      ),
    );
  }
}
