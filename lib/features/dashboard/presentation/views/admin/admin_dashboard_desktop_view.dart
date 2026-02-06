import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/repositories/admin_dashboard_repository.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_bloc.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_event.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/bloc/admin/admin_dashboard_state.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_stat_card.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/high_risk_alerts_banner.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_date_filter.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_category_filter.dart';
import 'package:airmenuai_partner_app/features/dashboard/presentation/widgets/shared/dashboard_search_field.dart';
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

                  // Row 1: Active Restaurants, Pending Onboarding, Orders Today (3 cards)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Restaurants
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[0],
                          index: 0,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Pending Onboarding
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[1],
                          index: 1,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Orders Today (with breakdown)
                      Expanded(
                        flex: 2, // Make it wider to accommodate breakdown
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[2],
                          index: 2,
                          trailing: Container(
                            constraints: const BoxConstraints(maxWidth: 150),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Builder(
                                  builder: (context) {
                                    final chart = data.ordersByType;
                                    final dineIn =
                                        chart?.dineIn.fold(
                                          0,
                                          (sum, item) => sum + item,
                                        ) ??
                                        0;
                                    final takeaway =
                                        chart?.takeaway.fold(
                                          0,
                                          (sum, item) => sum + item,
                                        ) ??
                                        0;
                                    final qsr =
                                        chart?.qsr.fold(
                                          0,
                                          (sum, item) => sum + item,
                                        ) ??
                                        0;

                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        _buildOrderTypeRow(
                                          'Dine-in',
                                          NumberFormat.decimalPattern().format(
                                            dineIn,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildOrderTypeRow(
                                          'Takeaway',
                                          NumberFormat.decimalPattern().format(
                                            takeaway,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        _buildOrderTypeRow(
                                          'QSR',
                                          NumberFormat.decimalPattern().format(
                                            qsr,
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: GMV, Kitchen, Delivery, Riders (4 cards)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[3], // GMV
                          index: 3,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[4], // Kitchen Load
                          index: 4,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[5], // Delivery Success
                          index: 5,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardStatCard(
                          stat: data.stats.toStatCards()[6], // Active Riders
                          index: 6,
                        ),
                      ),
                    ],
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

                  SizedBox(
                    height: 500,
                    child: TopRestaurantsTable(
                      restaurants: data.topRestaurants,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
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

                  // Tables row
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
    return DashboardSkeletonLoader.desktop();
  }

  Widget _buildOrderTypeRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '$label:',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF6B7280),
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF111827),
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
