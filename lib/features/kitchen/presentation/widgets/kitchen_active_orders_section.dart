import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/features/admin_orders/presentation/widgets/admin_order_card.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_bloc.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_event.dart';
import 'package:airmenuai_partner_app/features/orders/presentation/bloc/orders_state.dart';
import 'package:airmenuai_partner_app/features/responsive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Vendor "Active Orders" section displayed at the top of the Kitchen Panel
/// Live Kitchen tab. Mirrors the admin orders feed (admin_orders_page) with a
/// status filter and AdminOrderCard grid. Tapping a card opens the same
/// OrderDetailsPage used by the admin (with full status / KOT / bill / refund /
/// manual-payment functionality).
class KitchenActiveOrdersSection extends StatelessWidget {
  const KitchenActiveOrdersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 12),
              _buildFilterTabs(context, state),
              const SizedBox(height: 12),
              _buildBody(context, state),
            ],
          ),
        );
      },
    );
  }

  // ── Header ────────────────────────────────────────────────────────────
  Widget _buildHeader(BuildContext context, OrdersState state) {
    final isRefreshing = state is OrdersLoaded && state.isRefreshing;
    final total = state is OrdersLoaded ? state.allOrders.length : 0;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.receipt_long_outlined,
              size: 18, color: Color(0xFFDC2626)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Active Orders',
                style: GoogleFonts.sora(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              Text(
                total > 0
                    ? '$total order${total == 1 ? '' : 's'} for your restaurant'
                    : 'Your incoming orders will appear here',
                style: GoogleFonts.sora(
                  fontSize: 11,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        // Live dot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFF22C55E),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('Live',
                  style: GoogleFonts.sora(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF16A34A))),
            ],
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () =>
              context.read<OrdersBloc>().add(const RefreshOrders()),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isRefreshing
                ? const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh, size: 16, color: Color(0xFF374151)),
          ),
        ),
      ],
    );
  }

  // ── Filter Tabs ───────────────────────────────────────────────────────
  Widget _buildFilterTabs(BuildContext context, OrdersState state) {
    final selectedStatus = state is OrdersLoaded
        ? state.selectedStatus ?? 'all'
        : 'all';

    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final apiFilters = orderStats?.filters;

    List<({String key, String label, int count})> filters;
    if (apiFilters != null && apiFilters.isNotEmpty) {
      filters = apiFilters
          .map((f) => (
                key: f.key ?? '',
                label: f.label ?? f.key ?? '',
                count: f.count ?? 0,
              ))
          .toList();
    } else if (state is OrdersLoaded) {
      final all = state.allOrders.isNotEmpty ? state.allOrders : state.orders;
      final counts = <String, int>{'all': all.length};
      for (final o in all) {
        final s = o.status?.toLowerCase() ?? 'pending';
        counts[s] = (counts[s] ?? 0) + 1;
      }
      filters = [
        (key: 'all', label: 'All', count: all.length),
        (key: 'pending', label: 'Pending', count: counts['pending'] ?? 0),
        (key: 'processing', label: 'Preparing', count: counts['processing'] ?? 0),
        (key: 'ready', label: 'Ready', count: counts['ready'] ?? 0),
        (key: 'delivered', label: 'Delivered', count: counts['delivered'] ?? 0),
        (key: 'cancelled', label: 'Cancelled', count: counts['cancelled'] ?? 0),
      ];
    } else {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isActive = selectedStatus.toLowerCase() == f.key ||
              (f.key == 'all' &&
                  (selectedStatus == 'All Status' ||
                      selectedStatus.toLowerCase() == 'all'));
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                final statusToSend = f.key == 'all' ? 'All Status' : f.key;
                context.read<OrdersBloc>().add(FilterByStatus(statusToSend));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF111827) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF111827)
                        : const Color(0xFFE5E7EB),
                  ),
                ),
                child: Text(
                  f.count > 0 ? '${f.label} (${f.count})' : f.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isActive ? Colors.white : const Color(0xFF374151),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state is OrdersInitial || state is OrdersLoading) {
      return _buildSkeleton(context);
    }

    if (state is OrdersError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.error_outline,
                  size: 36, color: Colors.grey.shade400),
              const SizedBox(height: 8),
              Text(
                'Failed to load orders',
                style: GoogleFonts.sora(
                    fontSize: 13, color: const Color(0xFF6B7280)),
              ),
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
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.inbox_outlined,
                  size: 48, color: Colors.grey.shade300),
              const SizedBox(height: 12),
              Text(
                'No orders yet',
                style: GoogleFonts.sora(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'New orders will appear here',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);

    if (isMobile) {
      return Column(
        children: orders.map((o) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AdminOrderCard(
              order: o,
              onTap: () => _openDetails(context, o),
            ),
          );
        }).toList(),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: isTablet ? 1.55 : 1.65,
      ),
      itemBuilder: (context, index) {
        final order = orders[index];
        return AdminOrderCard(
          order: order,
          onTap: () => _openDetails(context, order),
        );
      },
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final crossAxisCount = isMobile ? 1 : 3;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: crossAxisCount * 2,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: isMobile ? 2.2 : 1.65,
        ),
        itemBuilder: (_, __) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, OrderModel order) {
    context.push(AppRoutes.kitchenOrderDetails.path, extra: order);
  }
}
