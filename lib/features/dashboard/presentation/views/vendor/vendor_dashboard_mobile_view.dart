import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/repositories/vendor_dashboard_repository.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/vendor/vendor_dashboard_bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/vendor/vendor_dashboard_event.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/vendor/vendor_dashboard_state.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/vendor_stat_card.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/vendor_dashboard_skeleton.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/orders_over_time_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/category_performance_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/order_type_breakdown_chart.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/bestselling_items_widget.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/recent_orders_table.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/vendor_quick_actions.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/dashboard_filter_bar.dart';

class VendorDashboardMobileView extends StatelessWidget {
  const VendorDashboardMobileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VendorDashboardBloc(repository: VendorDashboardRepositoryImpl())
            ..add(const LoadVendorDashboardData()),
      child: const _VendorDashboardMobileContent(),
    );
  }
}

class _VendorDashboardMobileContent extends StatelessWidget {
  const _VendorDashboardMobileContent();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VendorDashboardBloc, VendorDashboardState>(
      builder: (context, state) {
        if (state is VendorDashboardLoading) {
          return const VendorDashboardSkeleton();
        }

        if (state is VendorDashboardError) {
          return _buildErrorState(context, state);
        }

        if (state is VendorDashboardEmpty) {
          return _buildEmptyState(context);
        }

        if (state is VendorDashboardLoaded ||
            state is VendorDashboardRefreshing) {
          final data = state is VendorDashboardLoaded
              ? state.data
              : (state as VendorDashboardRefreshing).currentData;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<VendorDashboardBloc>().add(
                const RefreshVendorDashboardData(),
              );
              await Future.delayed(const Duration(seconds: 1));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Dashboard',
                      style: AirMenuTextStyle.headingH3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AirMenuColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Spice Garden - Today',
                      style: AirMenuTextStyle.small.copyWith(
                        color: AirMenuColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DashboardFilterBar(
                        selectedPeriod: state is VendorDashboardLoaded
                            ? state.dateRange
                            : 'Today',
                        selectedOrderType: state is VendorDashboardLoaded
                            ? state.orderType
                            : 'All Types',
                        selectedBranch: state is VendorDashboardLoaded
                            ? state.branch
                            : 'Main Branch',
                        availableBranches: state is VendorDashboardLoaded
                            ? state.availableBranches
                            : [],
                        onPeriodChanged: (value) {
                          context.read<VendorDashboardBloc>().add(
                            UpdateDashboardFilters(period: value),
                          );
                        },
                        onOrderTypeChanged: (value) {
                          context.read<VendorDashboardBloc>().add(
                            UpdateDashboardFilters(orderType: value),
                          );
                        },
                        onBranchChanged: (value) {
                          context.read<VendorDashboardBloc>().add(
                            UpdateDashboardFilters(branch: value),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stat Cards (1 column on mobile)
                    ...data.stats.toStatCards().asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: VendorStatCard(
                          data: entry.value,
                          index: entry.key,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Orders Over Time Chart
                    OrdersOverTimeChart(
                      data: data.ordersOverTime,
                      onViewDetails: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View Details clicked')),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Category Performance Chart
                    CategoryPerformanceChart(
                      data: data.categoryPerformance,
                      onViewAll: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('View All clicked')),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Order Type Breakdown
                    OrderTypeBreakdownChart(data: data.orderTypeBreakdown),

                    const SizedBox(height: 16),

                    // Bestselling Items
                    BestsellingItemsWidget(
                      items: data.bestsellingItems,
                      onViewAll: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View All Bestsellers clicked'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Recent Orders Table
                    RecentOrdersTable(
                      orders: data.recentOrders,
                      onViewAll: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('View All Orders clicked'),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Quick Actions
                    const VendorQuickActions(),

                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildErrorState(BuildContext context, VendorDashboardError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 56, color: AirMenuColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
                color: AirMenuColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: AirMenuTextStyle.small.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<VendorDashboardBloc>().add(
                  const LoadVendorDashboardData(),
                );
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inbox_outlined,
              size: 56,
              color: AirMenuColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Data',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
                color: AirMenuColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There is no dashboard data to display.',
              textAlign: TextAlign.center,
              style: AirMenuTextStyle.small.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
