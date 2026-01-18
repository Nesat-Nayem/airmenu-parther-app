import 'package:airmenuai_partner_app/features/kitchen/data/models/kitchen_task_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_bloc.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_event.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/bloc/kitchen_state.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/widgets/kitchen_order_card.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/widgets/station_filter_tabs.dart';

import 'package:airmenuai_partner_app/widgets/status_tile.dart';
import 'package:airmenuai_partner_app/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Kitchen Panel View - Kitchen Display System (KDS)
/// Matches Lovable mockup exactly with stats, filters, orders grid, and ready section
class KitchenPanelView extends StatefulWidget {
  const KitchenPanelView({super.key});

  @override
  State<KitchenPanelView> createState() => _KitchenPanelViewState();
}

class _KitchenPanelViewState extends State<KitchenPanelView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<KitchenBloc>().add(const RefreshKitchenOrders());
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: BlocConsumer<KitchenBloc, KitchenState>(
            listener: (context, state) {
              if (state is OrderPrepStarted) {
                AppSnackbar.success(context, 'Task started!');
              } else if (state is OrderMarkedReady) {
                AppSnackbar.success(context, 'Task marked as ready!');
              } else if (state is KitchenActionFailure) {
                AppSnackbar.error(context, state.message);
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  // Scrollable content
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Stats Row - Using common StatusTilesRow widget
                          _buildStatsRow(context, state),

                          // Station Filter Tabs
                          _buildStationTabs(context, state),
                          const SizedBox(height: 8),
                          // Orders Grid
                          _buildOrdersGrid(context, state),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),
                  // Ready for Pickup Section - Sticky at bottom
                  _buildReadyForPickupSection(context, state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, KitchenState state) {
    if (state is KitchenLoading) {
      return _buildStatsSkeleton();
    }

    final stats = state is KitchenLoaded ? state.stats : const KitchenStats();

    // Use common StatusTilesRow (same as Live Orders page)
    return StatusTilesRow(
      tiles: [
        // Active Stations - Red/Pink icon
        StatusTile(
          icon: Icons.restaurant_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: stats.activeStations,
          label: 'Active Stations',
        ),
        // Orders in Queue - Red/Pink icon
        StatusTile(
          icon: Icons.receipt_long_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: stats.ordersInQueue,
          label: 'Orders in Queue',
        ),
        // Avg Prep Time - Red/Pink icon with comparison badge
        StatusTile(
          icon: Icons.timer_outlined,
          iconBgColor: const Color(0xFFFEE2E2),
          iconColor: const Color(0xFFDC2626),
          count: stats.avgPrepTimeMinutes,
          label: 'Avg Prep Time',
          subtitle: 'vs yesterday',
          comparisonBadge: '2%',
          isPositiveComparison: true,
          showMinSuffix: true,
        ),
        // Ready for Pickup - Green check
        StatusTile(
          icon: Icons.check_circle_outline,
          iconBgColor: const Color(0xFFDCFCE7),
          iconColor: const Color(0xFF16A34A),
          count: stats.readyForPickup,
          label: 'Ready for Pickup',
        ),
      ],
    );
  }

  Widget _buildStatsSkeleton() {
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

  Widget _buildStationTabs(BuildContext context, KitchenState state) {
    final selectedStation = state is KitchenLoaded
        ? state.selectedStation
        : 'All';
    final tasks = state is KitchenLoaded ? state.tasks : <KitchenTaskModel>[];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 12,
        runSpacing: 8,
        children: [
          // Station Filter Tabs
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width > 1200
                  ? 900
                  : MediaQuery.of(context).size.width > 800
                  ? 600
                  : double.infinity,
            ),
            child: StationFilterTabs(
              selectedStation: selectedStation,
              onStationSelected: (station) {
                context.read<KitchenBloc>().add(FilterByStation(station));
              },
              tasks: tasks,
              stations: state is KitchenLoaded ? state.stations : [],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersGrid(BuildContext context, KitchenState state) {
    if (state is KitchenLoading) {
      return _buildOrdersSkeleton();
    }

    if (state is KitchenError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('Failed to load tasks'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () =>
                  context.read<KitchenBloc>().add(const LoadKitchenOrders()),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final tasks = state is KitchenLoaded
        ? state.kitchenTasks
        : <KitchenTaskModel>[];

    if (tasks.isEmpty && state is KitchenLoaded) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 64),
            Icon(
              Icons.restaurant_menu_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No tasks in kitchen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'New orders will appear here',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
            ),
          ],
        ),
      );
    }

    // Group tasks by orderId
    final groupedTasks = <String, List<KitchenTaskModel>>{};
    for (final task in tasks) {
      groupedTasks.putIfAbsent(task.orderId, () => []);
      groupedTasks[task.orderId]!.add(task);
    }
    final orderIds = groupedTasks.keys.toList();

    if (state is KitchenLoaded && state.isQueueLoading) {
      return _buildOrdersSkeleton();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          // Use MaxCrossAxisExtent logic for consistent tile widths
          const double maxCardWidth = 400.0;
          int crossAxisCount = (width / maxCardWidth).ceil();
          if (crossAxisCount < 1) crossAxisCount = 1;

          const double gap = 12.0;
          final double cardWidth =
              (width - gap * (crossAxisCount - 1)) / crossAxisCount;

          final rows = <List<String>>[];
          for (var i = 0; i < orderIds.length; i += crossAxisCount) {
            rows.add(
              orderIds.sublist(
                i,
                (i + crossAxisCount) > orderIds.length
                    ? orderIds.length
                    : i + crossAxisCount,
              ),
            );
          }

          return Column(
            children: rows.map((rowIds) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: rowIds.map((orderId) {
                      final orderTasks = groupedTasks[orderId]!;
                      final isLoading =
                          state is KitchenLoaded &&
                          orderTasks.any(
                            (t) => state.loadingIds.contains(t.id),
                          );

                      return Padding(
                        padding: EdgeInsets.only(
                          right: orderId != rowIds.last ? gap : 0,
                        ),
                        child: SizedBox(
                          width: cardWidth,
                          child: KitchenOrderCard(
                            tasks: orderTasks,
                            isLoading: isLoading,
                            onStartPrep: () {
                              for (final task in orderTasks) {
                                if (task.status.toUpperCase() == 'QUEUED') {
                                  context.read<KitchenBloc>().add(
                                    UpdateTaskStatus(
                                      taskId: task.id,
                                      status: 'IN_PROGRESS',
                                    ),
                                  );
                                }
                              }
                            },
                            onMarkReady: () {
                              for (final task in orderTasks) {
                                if (task.status.toUpperCase() ==
                                    'IN_PROGRESS') {
                                  context.read<KitchenBloc>().add(
                                    UpdateTaskStatus(
                                      taskId: task.id,
                                      status: 'DONE',
                                    ),
                                  );
                                }
                              }
                            },
                            onTap: () {},
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildOrdersSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const double maxCardWidth = 350.0;
          int crossAxisCount = (width / maxCardWidth).ceil();
          if (crossAxisCount < 1) crossAxisCount = 1;
          if (crossAxisCount > 4) crossAxisCount = 4;

          const double gap = 16.0;
          final double cardWidth =
              (width - gap * (crossAxisCount - 1)) / crossAxisCount;

          return Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.grey.shade50,
            child: Wrap(
              spacing: gap,
              runSpacing: gap,
              children: List.generate(crossAxisCount * 2, (index) {
                return Container(
                  width: cardWidth,
                  height: 220,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 60,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Container(
                            width: 50,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Type badge
                      Container(
                        width: 70,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Items
                      ...List.generate(
                        3,
                        (i) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 24,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      // Button
                      Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildReadyForPickupSection(BuildContext context, KitchenState state) {
    final readyOrders = state is KitchenLoaded
        ? state.readyOrders
        : <OrderModel>[];

    if (readyOrders.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, -2),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 14,
                  color: Color(0xFF16A34A),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Ready for Pickup',
                style: GoogleFonts.sora(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              const Spacer(),
              Text(
                '${readyOrders.length} orders',
                style: GoogleFonts.sora(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: readyOrders.map((order) {
                return _ReadyOrderCard(
                  order: order,
                  isLoading:
                      state is KitchenLoaded &&
                      state.loadingIds.contains(order.id),
                  onTap: () {
                    final orderId = order.id ?? '';
                    if (orderId.isNotEmpty &&
                        state is KitchenLoaded &&
                        !state.loadingIds.contains(orderId)) {
                      context.read<KitchenBloc>().add(MarkOrderPicked(orderId));
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadyOrderCard extends StatefulWidget {
  final OrderModel order;
  final bool isLoading;
  final VoidCallback onTap;

  const _ReadyOrderCard({
    required this.order,
    required this.isLoading,
    required this.onTap,
  });

  @override
  State<_ReadyOrderCard> createState() => _ReadyOrderCardState();
}

class _ReadyOrderCardState extends State<_ReadyOrderCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final orderId = widget.order.id ?? '';
    final shortId = orderId.length > 4
        ? orderId.substring(orderId.length - 4).toUpperCase()
        : orderId.padLeft(4, '0');

    final itemCount = widget.order.items?.length ?? 0;
    final orderType = widget.order.orderType?.toLowerCase() ?? 'dine_in';
    final isDelivery = orderType == 'delivery';
    final isTakeaway = orderType == 'takeaway';

    String typeLabel = 'dine in';
    if (isDelivery) typeLabel = 'delivery';
    if (isTakeaway) typeLabel = 'takeaway';

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -2.0 : 0.0),
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFFD1FAE5), const Color(0xFFE0F7E8)],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF10B981)
                : const Color(0xFFA7F3D0),
            width: 1.5,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF10B981).withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Order ID and X button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#$shortId',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF065F46),
                  ),
                ),
                // X button to dismiss
                GestureDetector(
                  onTap: widget.onTap,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: _isHovered
                          ? const Color(0xFF10B981)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: widget.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(4),
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF065F46),
                            ),
                          )
                        : Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: _isHovered
                                ? Colors.white
                                : const Color(0xFF065F46),
                          ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Order type
            Text(
              typeLabel,
              style: GoogleFonts.sora(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF047857),
              ),
            ),
            const SizedBox(height: 4),
            // Items count
            Text(
              '$itemCount ${itemCount == 1 ? 'item' : 'items'}',
              style: GoogleFonts.sora(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
