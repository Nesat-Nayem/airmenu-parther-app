import 'package:airmenuai_partner_app/features/admin_orders/presentation/widgets/admin_order_card.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Admin Live Orders Feed — Lovable LiveOrdersFeed look/feel.
/// Bloc search / filter / refresh / pagination / navigation preserved.
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

  static const _canvas = Color(0xFFFCFBF9);
  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);
  static const _idleBorder = Color(0xFFECE8E6);
  static const _accent = Color(0xFFD4353A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _canvas,
      body: SafeArea(
        child: RefreshIndicator(
          color: _accent,
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
                    if (metrics.pixels >= metrics.maxScrollExtent * 0.8) {
                      context.read<OrdersBloc>().add(const LoadMoreOrders());
                    }
                  }
                  return false;
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildStatusTiles(context, state),
                    ),
                    SliverToBoxAdapter(child: _buildToolbar(context, state)),
                    SliverToBoxAdapter(child: _buildFilterTabs(context, state)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                      sliver: _buildOrdersGrid(context, state),
                    ),
                    if (state is OrdersLoaded && state.isLoadingMore)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        sliver: _buildLoadMoreSkeleton(context),
                      ),
                    if (state is OrdersLoaded && state.hasReachedMax)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Text(
                              'All orders loaded',
                              style: GoogleFonts.sora(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: _muted,
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

    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final stats = orderStats?.stats;

    if (stats != null && stats.isNotEmpty) {
      return StatusTilesRow(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        tiles: stats.map((stat) {
          final shouldShowComparison = _shouldShowComparisonBadge(
            stat.comparison,
            stat.trend,
          );
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

    if (state is OrdersLoaded) {
      final allOrders =
          state.allOrders.isNotEmpty ? state.allOrders : state.orders;
      if (allOrders.isEmpty) return _buildSkeletonTiles();

      int active = 0;
      int delayed = 0;
      int completed = 0;
      for (final order in allOrders) {
        final s = order.status?.toLowerCase() ?? '';
        if (s == 'delivered' || s == 'completed') {
          completed++;
        } else if (s != 'cancelled') {
          active++;
          if (order.createdAt != null) {
            try {
              final created = DateTime.parse(order.createdAt!);
              if (DateTime.now().difference(created).inMinutes > 30) delayed++;
            } catch (_) {}
          }
        }
      }

      return StatusTilesRow(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        tiles: [
          StatusTile(
            icon: Icons.shopping_bag_outlined,
            iconBgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            count: active,
            label: 'Active Orders',
          ),
          StatusTile(
            icon: Icons.timer_outlined,
            iconBgColor: const Color(0xFFFEF3C7),
            iconColor: const Color(0xFFD97706),
            count: allOrders.length,
            label: 'Total Orders',
          ),
          StatusTile(
            icon: Icons.warning_amber_outlined,
            iconBgColor: const Color(0xFFFEE2E2),
            iconColor: const Color(0xFFDC2626),
            count: delayed,
            label: 'Delayed',
          ),
          StatusTile(
            icon: Icons.check_circle_outlined,
            iconBgColor: const Color(0xFFDCFCE7),
            iconColor: const Color(0xFF16A34A),
            count: completed,
            label: 'Completed',
          ),
        ],
      );
    }

    return _buildSkeletonTiles();
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
        return Icons.shopping_bag_outlined;
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
        return const Color(0xFFFEE2E2);
      case 'avgpreptime':
        return const Color(0xFFFEF3C7);
      case 'delayed':
        return const Color(0xFFFEE2E2);
      case 'completed':
        return const Color(0xFFDCFCE7);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _getIconColorForKey(String? key) {
    switch (key?.toLowerCase()) {
      case 'activeorders':
        return const Color(0xFFDC2626);
      case 'avgpreptime':
        return const Color(0xFFD97706);
      case 'delayed':
        return const Color(0xFFDC2626);
      case 'completed':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Widget _buildSkeletonTiles() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
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
                  height: 120,
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 720;
          final search = _buildSearchField(context);
          final restaurant = _buildRestaurantFilter(context, state);
          final liveRefresh = _buildLiveAndRefresh(context, isRefreshing);

          if (isNarrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (restaurant is! SizedBox) ...[
                      Flexible(child: restaurant),
                      const SizedBox(width: 10),
                    ],
                    liveRefresh,
                  ],
                ),
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: search),
              const SizedBox(width: 12),
              restaurant,
              const Spacer(),
              liveRefresh,
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _idleBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search, size: 18, color: Colors.grey.shade400),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search orders...',
                hintStyle: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _foreground,
              ),
              onChanged: (query) {
                context.read<OrdersBloc>().add(SearchOrders(query));
              },
            ),
          ),
          const SizedBox(width: 14),
        ],
      ),
    );
  }

  Widget _buildLiveAndRefresh(BuildContext context, bool isRefreshing) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: _idleBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF22C55E).withValues(alpha: 0.45),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Live',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF16A34A),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: () =>
                context.read<OrdersBloc>().add(const RefreshOrders()),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _idleBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRefreshing)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    Icon(Icons.refresh, size: 16, color: Colors.grey.shade700),
                  const SizedBox(width: 6),
                  Text(
                    'Refresh',
                    style: GoogleFonts.sora(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantFilter(BuildContext context, OrdersState state) {
    if (state is! OrdersLoaded) return const SizedBox.shrink();

    final restaurants = state.uniqueRestaurants;
    if (restaurants.isEmpty) return const SizedBox.shrink();

    final selectedId = state.selectedRestaurantId;

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: selectedId != null
            ? const Color(0xFFFEE2E2).withValues(alpha: 0.45)
            : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selectedId != null
              ? _accent.withValues(alpha: 0.35)
              : _idleBorder,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: selectedId,
          hint: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.store_outlined, size: 16, color: Colors.grey.shade500),
              const SizedBox(width: 6),
              Text(
                'All Restaurants',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          icon: Icon(
            Icons.keyboard_arrow_down,
            size: 18,
            color: Colors.grey.shade500,
          ),
          isDense: true,
          borderRadius: BorderRadius.circular(12),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text(
                'All Restaurants',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
            ...restaurants.map(
              (r) => DropdownMenuItem<String?>(
                value: r.id,
                child: Text(
                  r.name,
                  style: GoogleFonts.sora(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _foreground,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged: (value) {
            context.read<OrdersBloc>().add(FilterByRestaurant(value));
          },
        ),
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, OrdersState state) {
    final selectedStatus = state is OrdersLoaded
        ? state.selectedStatus ?? 'all'
        : 'all';

    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final apiFilters = orderStats?.filters;

    if (apiFilters == null || apiFilters.isEmpty) {
      if (state is! OrdersLoaded) return _buildFilterTabsSkeleton();
      final allOrders =
          state.allOrders.isNotEmpty ? state.allOrders : state.orders;
      if (allOrders.isEmpty) return _buildFilterTabsSkeleton();

      final counts = <String, int>{'all': allOrders.length};
      for (final order in allOrders) {
        final s = order.status?.toLowerCase() ?? 'pending';
        counts[s] = (counts[s] ?? 0) + 1;
      }

      final fallbackFilters = [
        ('all', 'All', allOrders.length),
        ('pending', 'Pending', counts['pending'] ?? 0),
        ('processing', 'Preparing', counts['processing'] ?? 0),
        ('ready', 'Ready', counts['ready'] ?? 0),
        ('delivered', 'Delivered', counts['delivered'] ?? 0),
      ];

      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: fallbackFilters.map((f) {
              final (key, label, count) = f;
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
                    context.read<OrdersBloc>().add(
                      FilterByStatus(statusToSend),
                    );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
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
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
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
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersGrid(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return _buildOrdersGridSkeleton(context);
    }

    if (state is OrdersError) {
      return SliverToBoxAdapter(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Failed to load orders',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: _muted,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    context.read<OrdersBloc>().add(const LoadOrders()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                ),
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
                  style: GoogleFonts.sora(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final order = orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: AdminOrderCard(
              order: order,
              onTap: () => _showOrderDetail(context, order),
            ),
          );
        }, childCount: orders.length),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: AdminOrderCardLayout.cardHeight,
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

  Widget _buildOrdersGridSkeleton(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: AdminOrderCardLayout.cardHeight,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const AdminOrderCardSkeleton(),
        childCount: crossAxisCount * 2,
      ),
    );
  }

  /// Load-more placeholders — same card height/layout as real order cards.
  Widget _buildLoadMoreSkeleton(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    if (isMobile) {
      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => const Padding(
            padding: EdgeInsets.only(bottom: 14),
            child: AdminOrderCardSkeleton(),
          ),
          childCount: 2,
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        mainAxisExtent: AdminOrderCardLayout.cardHeight,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) => const AdminOrderCardSkeleton(),
        childCount: crossAxisCount,
      ),
    );
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    context.push(AppRoutes.adminOrderDetails.path, extra: order);
  }
}

/// Lovable stage tab — coral active, soft secondary idle.
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

  static const _accent = Color(0xFFD4353A);
  static const _idleBorder = Color(0xFFECE8E6);
  static const _muted = Color(0xFF7A8494);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? _accent : const Color(0xFFF5F3F1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive ? _accent : _idleBorder,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: _accent.withValues(alpha: 0.22),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          count > 0 ? '$label ($count)' : label,
          style: GoogleFonts.sora(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : _muted,
          ),
        ),
      ),
    );
  }
}
