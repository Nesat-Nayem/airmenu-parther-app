import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
import 'package:airmenuai_partner_app/features/orders/config/order_status_helper.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/widgets/order_card_new.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/widgets/order_detail_dialog.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Orders Page View - Restaurant order management with Kanban-style layout
/// Designed for fast, efficient order tracking during peak hours
/// Note: BlocProvider is set up in the parent OrdersPage (order_page.dart)
class OrdersPageView extends StatelessWidget {
  const OrdersPageView({super.key});

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
              return CustomScrollView(
                slivers: [
                  // Status Tiles
                  SliverToBoxAdapter(child: _buildStatusTiles(context, state)),
                  // Toolbar (Search + Controls)
                  SliverToBoxAdapter(child: _buildToolbar(context, state)),
                  // Filter Tabs
                  SliverToBoxAdapter(child: _buildFilterTabs(context, state)),
                  // Orders Display (Kanban or List)
                  SliverFillRemaining(
                    child: _buildOrdersDisplay(context, state),
                  ),
                ],
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

    final counts = state is OrdersLoaded ? state.tileCounts : <String, int>{};
    final pendingCount = counts['pending'] ?? 0;
    final processingCount = counts['processing'] ?? 0;
    final readyCount = counts['ready'] ?? 0;
    final delayedCount = _calculateDelayedCount(
      state is OrdersLoaded ? state.allOrders : [],
    );

    return StatusTilesRow(
      tiles: [
        // Pending - Red/Pink icon (matching mock)
        StatusTile(
          icon: Icons.access_time_outlined,
          iconBgColor: const Color(0xFFFEE2E2), // Light pink/red
          iconColor: const Color(0xFFDC2626), // Red
          count: pendingCount,
          label: 'Pending',
        ),
        // In Kitchen - Red/Pink icon (matching mock)
        StatusTile(
          icon: Icons.inventory_2_outlined, // Box icon like mock
          iconBgColor: const Color(0xFFFEE2E2), // Light pink/red
          iconColor: const Color(0xFFDC2626), // Red
          count: processingCount,
          label: 'In Kitchen',
        ),
        // Ready - Red/Pink icon (matching mock)
        StatusTile(
          icon: Icons.check_circle_outline_rounded,
          iconBgColor: const Color(0xFFFEE2E2), // Light pink/red
          iconColor: const Color(0xFFDC2626), // Red
          count: readyCount,
          label: 'Ready',
        ),
        // Delayed - Red/Pink icon with comparison badge
        StatusTile(
          icon: Icons.warning_amber_outlined,
          iconBgColor: const Color(0xFFFEE2E2), // Light pink/red
          iconColor: const Color(0xFFDC2626), // Red
          count: delayedCount,
          label: 'Delayed',
          subtitle: 'vs yesterday',
          comparisonBadge: '50%',
          isPositiveComparison: true,
        ),
      ],
    );
  }

  int _calculateDelayedCount(List<OrderModel> orders) {
    int count = 0;
    for (final order in orders) {
      if (order.createdAt == null) continue;
      try {
        final created = DateTime.parse(order.createdAt!);
        if (DateTime.now().difference(created).inMinutes >
                OrderConfig.delayedThresholdMinutes &&
            order.status?.toLowerCase() != 'delivered' &&
            order.status?.toLowerCase() != 'cancelled') {
          count++;
        }
      } catch (_) {}
    }
    return count;
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
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 50,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 80,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
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
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final isSmallScreen = isMobile || isTablet;
    final isGridView = state is OrdersLoaded ? state.isGridView : true;
    final isRefreshing = state is OrdersLoaded && state.isRefreshing;
    final searchFocused = ValueNotifier<bool>(false);

    // Build the controls row (Live, Toggle, Refresh)
    Widget buildControls() {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live indicator with pulse
          _LiveIndicator(),
          const SizedBox(width: 12),
          // View toggle container
          Container(
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _ViewToggleBtn(
                  icon: Icons.grid_view_rounded,
                  isActive: isGridView,
                  onTap: () {
                    if (!isGridView) {
                      context.read<OrdersBloc>().add(const ToggleView());
                    }
                  },
                  isFirst: true,
                ),
                _ViewToggleBtn(
                  icon: Icons.format_list_bulleted_rounded,
                  isActive: !isGridView,
                  onTap: () {
                    if (isGridView) {
                      context.read<OrdersBloc>().add(const ToggleView());
                    }
                  },
                  isFirst: false,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Refresh button with border
          _PremiumButton(
            icon: isRefreshing ? null : Icons.sync_rounded,
            label: 'Refresh',
            isLoading: isRefreshing,
            onTap: () => context.read<OrdersBloc>().add(const RefreshOrders()),
          ),
        ],
      );
    }

    // Build search field
    Widget buildSearchField() {
      return Expanded(
        child: ValueListenableBuilder<bool>(
          valueListenable: searchFocused,
          builder: (context, focused, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 44,
              decoration: BoxDecoration(
                color: focused ? Colors.white : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: focused
                      ? AirMenuColors.primary.withValues(alpha: 0.5)
                      : Colors.grey.shade200,
                ),
                boxShadow: focused
                    ? [
                        BoxShadow(
                          color: AirMenuColors.primary.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 0,
                        ),
                      ]
                    : null,
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
                          context.read<OrdersBloc>().add(SearchOrders(query));
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );
    }

    // For small screens: wrap into 2 rows
    if (isSmallScreen) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Row 1: Search + Filter
            Row(
              children: [
                buildSearchField(),
                const SizedBox(width: 12),
                _PremiumIconButton(
                  icon: Icons.filter_alt_outlined,
                  onTap: () {
                    // TODO: Show filter modal
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Row 2: Live + Toggle + Refresh (scrollable if needed)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: buildControls(),
            ),
          ],
        ),
      );
    }

    // Desktop: single row layout
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          // Search field with focus glow
          Expanded(
            flex: 1,
            child: ValueListenableBuilder<bool>(
              valueListenable: searchFocused,
              builder: (context, focused, _) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 44,
                  decoration: BoxDecoration(
                    color: focused ? Colors.white : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: focused
                          ? AirMenuColors.primary.withValues(alpha: 0.5)
                          : Colors.grey.shade200,
                    ),
                    boxShadow: focused
                        ? [
                            BoxShadow(
                              color: AirMenuColors.primary.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 20,
                              spreadRadius: 0,
                            ),
                          ]
                        : null,
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
          // Filter button with border
          _PremiumIconButton(
            icon: Icons.filter_alt_outlined,
            onTap: () {
              // TODO: Show filter modal
            },
          ),
          const Spacer(),
          buildControls(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, OrdersState state) {
    final counts = state is OrdersLoaded ? state.tileCounts : <String, int>{};
    final selectedStatus = state is OrdersLoaded
        ? state.selectedStatus ?? 'all'
        : 'all';

    // Use centralized filter tabs config
    final filters = OrderStatusHelper.getFilterTabs(counts);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final key = filter['key'] as String;
            final label = filter['label'] as String;
            final count = filter['count'] as int;
            final isActive =
                selectedStatus.toLowerCase() == key ||
                (key == 'all' &&
                    (selectedStatus == 'All Status' ||
                        selectedStatus.toLowerCase() == 'all'));

            return Padding(
              padding: const EdgeInsets.only(right: 12),
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

  Widget _buildOrdersDisplay(BuildContext context, OrdersState state) {
    final isGridView = state is OrdersLoaded ? state.isGridView : true;
    final isRefreshing = state is OrdersLoaded && state.isRefreshing;

    return Stack(
      children: [
        if (isGridView)
          _buildKanbanBoard(context, state)
        else
          _buildListView(context, state),
        if (isRefreshing)
          Container(
            color: Colors.white.withValues(alpha: 0.7),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildKanbanBoard(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return _buildKanbanSkeleton();
    }

    if (state is OrdersError) {
      return Center(
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
      );
    }

    final orders = state is OrdersLoaded
        ? state.filteredOrders
        : <OrderModel>[];
    final groupedOrders = _groupOrdersByStatus(orders);
    final columns = OrderStatusHelper.getKanbanColumns();

    return _HorizontalKanbanScroll(
      columns: columns,
      groupedOrders: groupedOrders,
      onOrderTap: (order) => _showOrderDetail(context, order),
    );
  }

  Widget _buildKanbanSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.grey.shade50,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              4, // 4 columns
              (index) => Container(
                width: 300,
                height: 400,
                margin: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    // Header skeleton
                    Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                    ),
                    // Body skeleton
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            // First card skeleton
                            Container(
                              height: 140,
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            // Second card skeleton
                            Container(
                              height: 140,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context, OrdersState state) {
    if (state is OrdersLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final orders = state is OrdersLoaded
        ? state.filteredOrders
        : <OrderModel>[];
    final isMobile = Responsive.isMobile(context);

    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: AirMenuTextStyle.normal.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    if (isMobile) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: OrderCardNew(
            order: orders[index],
            onTap: () => _showOrderDetail(context, orders[index]),
            onMenuTap: () => _showOrderDetail(context, orders[index]),
          ),
        ),
      );
    }

    // Desktop table view with horizontal padding
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Table header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                _tableHeader('ORDER', flex: 2),
                _tableHeader('SOURCE', flex: 2),
                _tableHeader('ITEMS', flex: 1),
                _tableHeader('AMOUNT', flex: 1),
                _tableHeader('STATUS', flex: 1, center: true),
                _tableHeader('TIME', flex: 1),
                _tableHeader('ACTION', flex: 1, center: true),
              ],
            ),
          ),
          // Table rows
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: orders.length,
              itemBuilder: (context, index) =>
                  _buildTableRow(context, orders[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableHeader(String title, {int flex = 1, bool center = false}) {
    return Expanded(
      flex: flex,
      child: center
          ? Center(
              child: Text(
                title,
                style: AirMenuTextStyle.caption.copyWith(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            )
          : Text(
              title,
              style: AirMenuTextStyle.caption.copyWith(
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    );
  }

  Widget _buildTableRow(BuildContext context, OrderModel order) {
    final shortId = _getShortOrderId(order);
    final kotNumber = _getKotNumber(order);
    final orderType = order.orderType?.toLowerCase() ?? 'dine_in';
    final tableNumber = order.tableNumber ?? '';
    final itemCount = order.items?.length ?? 0;
    final amount = order.totalAmount?.toInt() ?? 0;
    final status = order.status?.toLowerCase() ?? 'pending';
    final elapsedMinutes = _getElapsedMinutes(order);

    // Time color logic: warning (12-22 min), destructive (>22 min)
    Color timeColor = Colors.grey.shade700;
    if (elapsedMinutes >= 22) {
      timeColor = const Color(0xFFDC2626); // Destructive red
    } else if (elapsedMinutes >= 12) {
      timeColor = const Color(0xFFF59E0B); // Warning orange
    }

    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: () => _showOrderDetail(context, order),
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                color: hovered ? Colors.grey.shade50 : Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200.withValues(alpha: 0.5),
                  ),
                ),
              ),
              child: Row(
                children: [
                  // ORDER (id + KOT)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#$shortId',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF212121),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          kotNumber,
                          style: AirMenuTextStyle.caption.copyWith(
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // SOURCE (type + table)
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        Text(
                          _capitalizeFirst(orderType.replaceAll('_', ' ')),
                          style: AirMenuTextStyle.normal.copyWith(
                            color: const Color(0xFF374151),
                          ),
                        ),
                        if (tableNumber.isNotEmpty) ...[
                          Text(
                            ' • T-$tableNumber',
                            style: AirMenuTextStyle.normal.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  // ITEMS
                  Expanded(
                    flex: 1,
                    child: Text(
                      '$itemCount items',
                      style: AirMenuTextStyle.normal.copyWith(
                        color: const Color(0xFF374151),
                      ),
                    ),
                  ),
                  // AMOUNT
                  Expanded(
                    flex: 1,
                    child: Text(
                      '₹$amount',
                      style: AirMenuTextStyle.normal.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF212121),
                      ),
                    ),
                  ),
                  // STATUS (badge with dot) - centered, compact width
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.center,
                      child: _buildStatusBadge(status),
                    ),
                  ),
                  // TIME (color coded)
                  Expanded(
                    flex: 1,
                    child: Text(
                      _formatTime(elapsedMinutes),
                      overflow: TextOverflow.ellipsis,
                      style: AirMenuTextStyle.normal.copyWith(
                        color: timeColor,
                        fontWeight: elapsedMinutes >= 12
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                  ),
                  // ACTION (ellipsis button) - centered
                  Expanded(
                    flex: 1,
                    child: Center(
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => _showOrderDetail(context, order),
                            hoverColor: Colors.grey.shade200,
                            child: Center(
                              child: Icon(
                                Icons.more_horiz,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
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
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    Color dotColor;
    Color borderColor;
    String label;

    switch (status) {
      case 'pending':
        bgColor = const Color(0xFFFEF3C7).withValues(alpha: 0.5);
        textColor = const Color(0xFFF59E0B);
        dotColor = const Color(0xFFF59E0B);
        borderColor = const Color(0xFFFCD34D).withValues(alpha: 0.4);
        label = 'pending';
        break;
      case 'processing':
        bgColor = const Color(0xFFFEF3C7).withValues(alpha: 0.5);
        textColor = const Color(0xFFF59E0B);
        dotColor = const Color(0xFFF59E0B);
        borderColor = const Color(0xFFFCD34D).withValues(alpha: 0.4);
        label = 'in kitchen';
        break;
      case 'ready':
        bgColor = const Color(0xFFDCFCE7).withValues(alpha: 0.5);
        textColor = const Color(0xFF16A34A);
        dotColor = const Color(0xFF16A34A);
        borderColor = const Color(0xFF86EFAC).withValues(alpha: 0.4);
        label = 'ready';
        break;
      case 'delivered':
        bgColor = const Color(0xFFFEF3C7).withValues(alpha: 0.5);
        textColor = const Color(0xFFF59E0B);
        dotColor = const Color(0xFFF59E0B);
        borderColor = const Color(0xFFFCD34D).withValues(alpha: 0.4);
        label = 'served';
        break;
      case 'cancelled':
        bgColor = const Color(0xFFFEE2E2).withValues(alpha: 0.5);
        textColor = const Color(0xFFDC2626);
        dotColor = const Color(0xFFDC2626);
        borderColor = const Color(0xFFFCA5A5).withValues(alpha: 0.4);
        label = 'cancelled';
        break;
      default:
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade600;
        dotColor = Colors.grey.shade500;
        borderColor = Colors.grey.shade200;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showOrderDetail(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (dialogContext) => OrderDetailDialog(
        order: order,
        onStatusChange: (newStatus) {
          context.read<OrdersBloc>().add(
            UpdateOrderStatus(orderId: order.id ?? '', newStatus: newStatus),
          );
        },
      ),
    );
  }

  Map<String, List<OrderModel>> _groupOrdersByStatus(List<OrderModel> orders) {
    final grouped = <String, List<OrderModel>>{};
    for (final order in orders) {
      final status = order.status?.toLowerCase() ?? 'pending';
      grouped.putIfAbsent(status, () => []);
      grouped[status]!.add(order);
    }
    return grouped;
  }

  String _getShortOrderId(OrderModel order) {
    final id = order.id ?? '';
    return id.length > 4 ? id.substring(id.length - 4).toUpperCase() : id;
  }

  String _getKotNumber(OrderModel order) {
    final id = order.id ?? '';
    return 'KOT-${id.length > 3 ? id.substring(id.length - 3) : id}';
  }

  int _getElapsedMinutes(OrderModel order) {
    if (order.createdAt == null) return 0;
    try {
      final created = DateTime.parse(order.createdAt!);
      return DateTime.now().difference(created).inMinutes;
    } catch (_) {
      return 0;
    }
  }

  String _formatTime(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else if (minutes < 1440) {
      // Less than 24 hours - show hours
      final hours = minutes ~/ 60;
      return '$hours hrs';
    } else {
      // Show days
      final days = minutes ~/ 1440;
      return '$days days';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIEW TOGGLE BUTTON
// ─────────────────────────────────────────────────────────────────────────────

class _ViewToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isFirst;

  const _ViewToggleBtn({
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isFirst,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 36,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFFEE2E2) : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(7) : Radius.zero,
            right: !isFirst ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? const Color(0xFFDC2626) : Colors.grey.shade500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM ICON BUTTON (Filter, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _PremiumIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: hovered
                      ? AirMenuColors.primary.withValues(alpha: 0.4)
                      : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: hovered ? AirMenuColors.primary : Colors.grey.shade600,
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LIVE INDICATOR WITH PULSE
// ─────────────────────────────────────────────────────────────────────────────

class _LiveIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pulsing green dot
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: const Color(0xFF22C55E),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withValues(alpha: 0.4),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Live',
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFF22C55E),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PREMIUM BUTTON (Refresh, etc.)
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _PremiumButton({
    this.icon,
    required this.label,
    this.isLoading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: hovered ? Colors.grey.shade50 : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: hovered
                      ? AirMenuColors.primary.withValues(alpha: 0.4)
                      : Colors.grey.shade200,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AirMenuColors.primary,
                      ),
                    )
                  else if (icon != null)
                    Icon(
                      icon,
                      size: 16,
                      color: hovered
                          ? AirMenuColors.primary
                          : Colors.grey.shade600,
                    ),
                  if (icon != null || isLoading) const SizedBox(width: 8),
                  Text(
                    label,
                    style: AirMenuTextStyle.small.copyWith(
                      color: hovered
                          ? AirMenuColors.primary
                          : Colors.grey.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// FILTER CHIP
// ─────────────────────────────────────────────────────────────────────────────

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
    final isHovered = ValueNotifier<bool>(false);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => isHovered.value = true,
      onExit: (_) => isHovered.value = false,
      child: GestureDetector(
        onTap: onTap,
        child: ValueListenableBuilder<bool>(
          valueListenable: isHovered,
          builder: (context, hovered, _) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                // Active: red #DC2626, Inactive: gray background
                color: isActive
                    ? const Color(0xFFDC2626)
                    : (hovered ? Colors.grey.shade200 : Colors.grey.shade100),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label text with Sora font
                  Text(
                    label,
                    style: GoogleFonts.sora(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isActive
                          ? Colors.white
                          : (hovered
                                ? const Color(0xFF111827)
                                : Colors.grey.shade600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      // Active: semi-transparent white, Inactive: white
                      color: isActive
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.sora(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isActive
                            ? Colors.white
                            : const Color(0xFF374151),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HORIZONTAL KANBAN SCROLL (with mouse wheel + scrollbar sync)
// ─────────────────────────────────────────────────────────────────────────────

class _HorizontalKanbanScroll extends StatefulWidget {
  final List<Map<String, dynamic>> columns;
  final Map<String, List<OrderModel>> groupedOrders;
  final Function(OrderModel) onOrderTap;

  const _HorizontalKanbanScroll({
    required this.columns,
    required this.groupedOrders,
    required this.onOrderTap,
  });

  @override
  State<_HorizontalKanbanScroll> createState() =>
      _HorizontalKanbanScrollState();
}

class _HorizontalKanbanScrollState extends State<_HorizontalKanbanScroll> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: ScrollConfiguration(
        // Enable mouse drag scrolling on desktop
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: {
            PointerDeviceKind.touch,
            PointerDeviceKind.mouse,
            PointerDeviceKind.trackpad,
          },
        ),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          trackVisibility: true,
          interactive: true,
          thickness: 8,
          radius: const Radius.circular(10),
          child: SingleChildScrollView(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.columns.map((col) {
                final key = col['key'] as String;
                final label = col['label'] as String;
                final color = col['color'] as Color;
                final colOrders = widget.groupedOrders[key] ?? [];

                return _KanbanColumnNew(
                  label: label,
                  color: color,
                  count: colOrders.length,
                  orders: colOrders,
                  onOrderTap: widget.onOrderTap,
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KANBAN COLUMN
// ─────────────────────────────────────────────────────────────────────────────

class _KanbanColumnNew extends StatelessWidget {
  final String label;
  final Color color;
  final int count;
  final List<OrderModel> orders;
  final Function(OrderModel) onOrderTap;

  const _KanbanColumnNew({
    required this.label,
    required this.color,
    required this.count,
    required this.orders,
    required this.onOrderTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header with tinted background (matching HTML: rounded-t-xl, bg-{color}/5)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              // Light tinted background (5% opacity of status color)
              color: color.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Status dot (3x3 rounded-full)
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                // Label (capitalize first letter)
                Text(
                  label[0].toUpperCase() + label.substring(1).toLowerCase(),
                  style: AirMenuTextStyle.normal.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF212121),
                  ),
                ),
                const Spacer(),
                // Count (muted)
                Text(
                  '$count',
                  style: AirMenuTextStyle.small.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Column body with light gray background (matching HTML: rounded-b-xl, bg-secondary/20)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              constraints: const BoxConstraints(minHeight: 300),
              child: orders.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: orders.length,
                      itemBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: OrderCardNew(
                          order: orders[index],
                          onTap: () => onOrderTap(orders[index]),
                          onMenuTap: () => onOrderTap(orders[index]),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Empty state with shopping bag icon (matching HTML)
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 32,
              color: Colors.grey.shade400.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No orders',
              style: AirMenuTextStyle.small.copyWith(
                color: Colors.grey.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
