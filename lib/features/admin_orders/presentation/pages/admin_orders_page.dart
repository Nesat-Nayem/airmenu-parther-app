import 'package:airmenuai_partner_app/features/admin_orders/presentation/widgets/admin_order_card.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/widgets/order_detail_dialog.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Admin Live Orders Feed Page
/// Shows real-time orders across all restaurants with admin-specific stats
class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => OrdersBloc()..add(const LoadOrders()),
      child: const _AdminOrdersPageView(),
    );
  }
}

class _AdminOrdersPageView extends StatelessWidget {
  const _AdminOrdersPageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<OrdersBloc>().add(const RefreshOrders());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocBuilder<OrdersBloc, OrdersState>(
            builder: (context, state) {
              return NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is ScrollEndNotification) {
                    final metrics = notification.metrics;
                    // Trigger load more when reaching 80% of scroll extent
                    if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                      context.read<OrdersBloc>().add(const LoadMoreOrders());
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  slivers: [
                    // Status Tiles
                    SliverToBoxAdapter(
                      child: _buildStatusTiles(context, state),
                    ),
                    // Toolbar (Search + Controls)
                    SliverToBoxAdapter(child: _buildToolbar(context, state)),
                    // Filter Tabs
                    SliverToBoxAdapter(child: _buildFilterTabs(context, state)),
                    // Orders Grid
                    SliverPadding(
                      padding: const EdgeInsets.all(20),
                      sliver: _buildOrdersGrid(context, state),
                    ),
                    // Loading More Indicator
                    if (state is OrdersLoaded && state.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AirMenuColors.primary,
                            ),
                          ),
                        ),
                      ),
                    // End of list indicator
                    if (state is OrdersLoaded && state.hasReachedMax)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'All orders loaded',
                              style: AirMenuTextStyle.caption.copyWith(
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTiles(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return _buildSkeletonTiles();
    }

    // Get stats from API response
    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final stats = orderStats?.stats;

    // If no API stats, show skeleton
    if (stats == null || stats.isEmpty) {
      return _buildSkeletonTiles();
    }

    // Build tiles dynamically from API stats (admin format)
    return StatusTilesRow(
      tiles: stats.map((stat) {
        final shouldShowComparison = _shouldShowComparisonBadge(
          stat.comparison,
          stat.trend,
        );

        // Check if value is a string (like "18 min") vs integer
        final isStringValue = stat.value is String;

        return StatusTile(
          icon: _getIconForAdminStatKey(stat.key),
          iconBgColor: _getIconBgColorForKey(stat.key),
          iconColor: _getIconColorForKey(stat.key),
          count: stat.intValue,
          displayValue: isStringValue ? stat.displayValue : null,
          label: stat.label ?? stat.key ?? '',
          subtitle: shouldShowComparison ? stat.comparisonLabel : null,
          comparisonBadge: shouldShowComparison ? stat.comparison : null,
          isPositiveComparison: stat.isPositiveTrend,
        );
      }).toList(),
    );
  }

  bool _shouldShowComparisonBadge(String? comparison, String? trend) {
    if (comparison == null || comparison.isEmpty) return false;
    if (trend == 'neutral') return false;
    final numericValue = int.tryParse(
      comparison.replaceAll(RegExp(r'[^0-9-]'), ''),
    );
    if (numericValue == null || numericValue == 0) return false;
    return true;
  }

  IconData _getIconForAdminStatKey(String? key) {
    switch (key?.toLowerCase()) {
      case 'activeorders':
        return Icons.receipt_long_outlined;
      case 'avgpreptime':
        return Icons.timer_outlined;
      case 'delayed':
        return Icons.warning_amber_outlined;
      case 'completed':
        return Icons.check_circle_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Color _getIconBgColorForKey(String? key) {
    switch (key?.toLowerCase()) {
      case 'activeorders':
        return const Color(0xFFFEE2E2); // Light pink
      case 'avgpreptime':
        return const Color(0xFFFEF3C7); // Light yellow
      case 'delayed':
        return const Color(0xFFFEE2E2); // Light pink
      case 'completed':
        return const Color(0xFFDCFCE7); // Light green
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconColorForKey(String? key) {
    switch (key?.toLowerCase()) {
      case 'activeorders':
        return const Color(0xFFDC2626); // Red
      case 'avgpreptime':
        return const Color(0xFFD97706); // Orange
      case 'delayed':
        return const Color(0xFFDC2626); // Red
      case 'completed':
        return const Color(0xFF16A34A); // Green
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildSkeletonTiles() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index < 3 ? 16 : 0),
                child: Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, OrdersState state) {
    final isRefreshing = state is OrdersLoaded && state.isRefreshing;
    final searchFocused = ValueNotifier<bool>(false);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Search field
          Expanded(
            flex: 2,
            child: ValueListenableBuilder<bool>(
              valueListenable: searchFocused,
              builder: (context, focused, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 44,
                  decoration: BoxDecoration(
                    color: focused ? Colors.white : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: focused
                          ? AirMenuColors.primary.withValues(alpha: 0.5)
                          : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      Icon(Icons.search, size: 18, color: Colors.grey.shade400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Focus(
                          onFocusChange: (hasFocus) =>
                              searchFocused.value = hasFocus,
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Search orders...',
                              hintStyle: AirMenuTextStyle.small.copyWith(
                                color: Colors.grey.shade400,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                            style: AirMenuTextStyle.small.copyWith(
                              color: const Color(0xFF212121),
                            ),
                            onChanged: (query) {
                              context.read<OrdersBloc>().add(
                                SearchOrders(query),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Filter button
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: IconButton(
              icon: Icon(Icons.tune_outlined, color: Colors.grey.shade700),
              onPressed: () {},
            ),
          ),
          const Spacer(),
          // Live indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Live',
                  style: AirMenuTextStyle.small.copyWith(
                    color: const Color(0xFF16A34A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Refresh button
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: TextButton.icon(
              onPressed: () =>
                  context.read<OrdersBloc>().add(const RefreshOrders()),
              icon: isRefreshing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(Icons.refresh, size: 18, color: Colors.grey.shade700),
              label: Text(
                'Refresh',
                style: AirMenuTextStyle.small.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, OrdersState state) {
    final selectedStatus = state is OrdersLoaded
        ? state.selectedStatus ?? 'all'
        : 'all';

    // Get filters from API response
    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final apiFilters = orderStats?.filters;

    // If no API filters, show skeleton
    if (apiFilters == null || apiFilters.isEmpty) {
      return _buildFilterTabsSkeleton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: apiFilters.map((filter) {
            final key = filter.key ?? '';
            final label = filter.label ?? key;
            final count = filter.count ?? 0;
            final isActive =
                selectedStatus.toLowerCase() == key ||
                (key == 'all' &&
                    (selectedStatus == 'All Status' ||
                        selectedStatus.toLowerCase() == 'all'));

            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _FilterChip(
                label: label,
                count: count,
                isActive: isActive,
                onTap: () {
                  final statusToSend = key == 'all' ? 'All Status' : key;
                  context.read<OrdersBloc>().add(FilterByStatus(statusToSend));
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFilterTabsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: Row(
          children: List.generate(
            5,
            (index) => Container(
              margin: const EdgeInsets.only(right: 8),
              width: 80,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersGrid(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return _buildOrdersGridSkeleton();
    }

    if (state is OrdersError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text('Failed to load orders', style: AirMenuTextStyle.normal),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    context.read<OrdersBloc>().add(const LoadOrders()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final orders = state is OrdersLoaded
        ? state.filteredOrders
        : <OrderModel>[];

    if (orders.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(60),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No orders found',
                  style: AirMenuTextStyle.normal.copyWith(
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Responsive grid columns
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    // On mobile, use SliverList for natural heights (no overflow)
    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminOrderCard(
              order: order,
              onTap: () => _showOrderDetail(context, order),
            ),
          );
        }, childCount: orders.length),
      );
    }

    // Desktop/Tablet: Use grid with fixed aspect ratio
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: isTablet
            ? 1.55
            : 1.65, // Balanced: compact but no overflow
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final order = orders[index];
        return AdminOrderCard(
          order: order,
          onTap: () => _showOrderDetail(context, order),
        );
      }, childCount: orders.length),
    );
  }

  Widget _buildOrdersGridSkeleton() {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade50,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }, childCount: 6),
    );
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => OrderDetailDialog(order: order),
    );
  }
}

/// Filter chip widget for admin orders
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF111827) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? const Color(0xFF111827) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isActive ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
