import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/vendor/dashboard_filter_bar.dart';
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

class VendorDashboardDesktopView extends StatelessWidget {
  const VendorDashboardDesktopView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          VendorDashboardBloc(repository: VendorDashboardRepositoryImpl())
            ..add(const LoadVendorDashboardData()),
      child: const _VendorDashboardDesktopContent(),
    );
  }
}

class _VendorDashboardDesktopContent extends StatelessWidget {
  const _VendorDashboardDesktopContent();

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
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header

                    // Filters
                    Row(
                      children: [
                        // Search Field
                        Expanded(
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF9FAFB),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search,
                                  color: Color(0xFF9CA3AF),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search orders, items...',
                                      hintStyle: AirMenuTextStyle.normal
                                          .copyWith(
                                            color: const Color(0xFF9CA3AF),
                                          ),
                                      border: InputBorder.none,
                                      isDense: true,
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: const Color(0xFFE5E7EB),
                                    ),
                                  ),
                                  child: Text(
                                    '⌘K',
                                    style: AirMenuTextStyle.small.copyWith(
                                      color: const Color(0xFF9CA3AF),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Date Filter
                        DashboardFilterBar(
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
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Stat Cards (6 columns)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                0.55, // Taller ratio for overflow safety
                          ),
                      itemCount: data.stats.toStatCards().length,
                      itemBuilder: (context, index) {
                        final stat = data.stats.toStatCards()[index];

                        // Custom footer for 'Total Orders Today' card (index 0)
                        Widget? footer;
                        if (index == 0) {
                          footer = Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildBreakdownRow('Dine-in', '89'),
                              const SizedBox(height: 4),
                              _buildBreakdownRow('Takeaway', '45'),
                              const SizedBox(height: 4),
                              _buildBreakdownRow('Delivery', '22'),
                            ],
                          );
                        }

                        return VendorStatCard(
                          data: stat,
                          index: index,
                          footer: footer,
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Charts Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OrdersOverTimeChart(
                            data: data.ordersOverTime,
                            onViewDetails: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View Details clicked'),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: CategoryPerformanceChart(
                            data: data.categoryPerformance,
                            onViewAll: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View All clicked'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Bottom Charts Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: OrderTypeBreakdownChart(
                            data: data.orderTypeBreakdown,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BestsellingItemsWidget(
                            items: data.bestsellingItems,
                            onViewAll: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('View All Bestsellers clicked'),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

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

                    const SizedBox(height: 32),

                    // Quick Actions
                    const VendorQuickActions(),

                    const SizedBox(height: 24),
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
            Icon(Icons.error_outline, size: 64, color: AirMenuColors.error),
            const SizedBox(height: 16),
            Text(
              'Failed to Load Dashboard',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
                color: AirMenuColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: AirMenuTextStyle.normal.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.read<VendorDashboardBloc>().add(
                  const LoadVendorDashboardData(),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AirMenuColors.primary,
                foregroundColor: AirMenuColors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
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
              size: 64,
              color: AirMenuColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              'No Data Available',
              style: AirMenuTextStyle.headingH4.copyWith(
                fontWeight: FontWeight.bold,
                color: AirMenuColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There is no dashboard data to display at the moment.',
              textAlign: TextAlign.center,
              style: AirMenuTextStyle.normal.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF374151),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
