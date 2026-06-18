import 'package:airmenuai_partner_app/config/router/app_route_paths.dart';
import 'package:airmenuai_partner_app/features/kitchen/presentation/widgets/kitchen_active_order_card.dart';
import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
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

/// Vendor "Active Orders" section on the Kitchen panel Live tab.
/// Paginated grid backed by GET /orders (page + limit + status).
class KitchenActiveOrdersSection extends StatelessWidget {
  const KitchenActiveOrdersSection({super.key});

  static const _primary = Color(0xFFDC2626);

  static double _gridMainAxisExtent(BuildContext context) {
    if (Responsive.isMobile(context)) return 196;
    if (Responsive.isTablet(context)) return 206;
    return 206;
  }

  SliverGridDelegate _gridDelegate(BuildContext context) {
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);
    final crossAxisCount = isMobile ? 1 : (isTablet ? 2 : 3);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      mainAxisExtent: _gridMainAxisExtent(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrdersBloc, OrdersState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                const Color(0xFFF8FAFC),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context, state),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterTabs(context, state),
                    const SizedBox(height: 14),
                    _buildBody(context, state),
                    if (state is OrdersLoaded && state.orders.isNotEmpty)
                      _buildPagination(context, state),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, OrdersState state) {
    final isRefreshing = state is OrdersLoaded && state.isRefreshing;
    final total = state is OrdersLoaded
        ? (state.pagination.totalItems ?? state.orders.length)
        : 0;
    final page = state is OrdersLoaded ? state.currentPage : 1;
    final totalPages = state is OrdersLoaded
        ? (state.pagination.totalPages ?? 1)
        : 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEF2F6))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFEE2E2), Color(0xFFFECACA)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.receipt_long_rounded,
              size: 20,
              color: _primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Active Orders',
                  style: GoogleFonts.sora(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  total > 0
                      ? '$total order${total == 1 ? '' : 's'} · Page $page of $totalPages'
                      : 'Incoming orders appear here in real time',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          _LiveBadge(),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.refresh_rounded,
            loading: isRefreshing,
            onTap: () => context.read<OrdersBloc>().add(
              RefreshOrders(),
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

    final orderStats = state is OrdersLoaded ? state.orderStats : null;
    final apiFilters = orderStats?.filters;

    List<({String key, String label, int count})> filters;
    if (apiFilters != null && apiFilters.isNotEmpty) {
      filters = apiFilters
          .map(
            (f) => (
              key: f.key ?? '',
              label: f.label ?? f.key ?? '',
              count: f.count ?? 0,
            ),
          )
          .toList();
    } else if (state is OrdersLoaded) {
      final counts = state.tileCounts;
      filters = [
        (key: 'all', label: 'All', count: counts['all'] ?? 0),
        (key: 'pending', label: 'Pending', count: counts['pending'] ?? 0),
        (
          key: 'processing',
          label: 'Preparing',
          count: counts['processing'] ?? 0,
        ),
        (key: 'ready', label: 'Ready', count: counts['ready'] ?? 0),
        (
          key: 'delivered',
          label: 'Delivered',
          count: counts['delivered'] ?? 0,
        ),
        (
          key: 'cancelled',
          label: 'Cancelled',
          count: counts['cancelled'] ?? 0,
        ),
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
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(
                          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                        )
                      : null,
                  color: isActive ? null : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isActive
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFE2E8F0),
                  ),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.12),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  f.count > 0 ? '${f.label} (${f.count})' : f.label,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : const Color(0xFF475569),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBody(BuildContext context, OrdersState state) {
    if (state is OrdersInitial || state is OrdersLoading) {
      return _buildSkeleton(context);
    }

    if (state is OrdersError) {
      return _buildMessage(
        icon: Icons.cloud_off_rounded,
        title: 'Failed to load orders',
        action: TextButton(
          onPressed: () => context.read<OrdersBloc>().add(
            const LoadOrders(limit: OrderConfig.kitchenItemsPerPage),
          ),
          child: const Text('Retry'),
        ),
      );
    }

    if (state is OrdersEmpty) {
      return _buildMessage(
        icon: Icons.inbox_rounded,
        title: 'No orders yet',
        subtitle: 'New orders will show up here automatically',
      );
    }

    final orders = state is OrdersLoaded
        ? state.filteredOrders
        : <OrderModel>[];

    if (orders.isEmpty) {
      return _buildMessage(
        icon: Icons.filter_list_off_rounded,
        title: 'No orders in this filter',
        subtitle: 'Try another status tab',
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: orders.length,
      gridDelegate: _gridDelegate(context),
      itemBuilder: (context, index) {
        final order = orders[index];
        return KitchenActiveOrderCard(
          order: order,
          onTap: () => _openDetails(context, order),
        );
      },
    );
  }

  Widget _buildPagination(BuildContext context, OrdersLoaded state) {
    final current = state.currentPage;
    final totalPages = state.pagination.totalPages ?? 1;
    final totalItems = state.pagination.totalItems ?? state.orders.length;
    final isMobile = Responsive.isMobile(context);

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: isMobile
            ? Column(
                children: [
                  Text(
                    'Showing page $current of $totalPages ($totalItems orders)',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PageButton(
                          label: 'Previous',
                          icon: Icons.chevron_left_rounded,
                          enabled: state.canGoPrevious && !state.isRefreshing,
                          onTap: () => context.read<OrdersBloc>().add(
                            ChangePage(current - 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _PageButton(
                          label: 'Next',
                          icon: Icons.chevron_right_rounded,
                          iconAfter: true,
                          enabled: state.canGoNext && !state.isRefreshing,
                          onTap: () => context.read<OrdersBloc>().add(
                            ChangePage(current + 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Row(
                children: [
                  Text(
                    'Showing page $current of $totalPages',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '· $totalItems total',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  const Spacer(),
                  _PageButton(
                    label: 'Previous',
                    icon: Icons.chevron_left_rounded,
                    enabled: state.canGoPrevious && !state.isRefreshing,
                    onTap: () => context.read<OrdersBloc>().add(
                      ChangePage(current - 1),
                    ),
                  ),
                  const SizedBox(width: 6),
                  ..._pageNumberButtons(context, state),
                  const SizedBox(width: 6),
                  _PageButton(
                    label: 'Next',
                    icon: Icons.chevron_right_rounded,
                    iconAfter: true,
                    enabled: state.canGoNext && !state.isRefreshing,
                    onTap: () => context.read<OrdersBloc>().add(
                      ChangePage(current + 1),
                    ),
                  ),
                  if (state.isRefreshing) ...[
                    const SizedBox(width: 12),
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ],
                ],
              ),
      ),
    );
  }

  List<Widget> _pageNumberButtons(BuildContext context, OrdersLoaded state) {
    final current = state.currentPage;
    final total = state.pagination.totalPages ?? 1;
    final start = (current - 2).clamp(1, total);
    final end = (current + 2).clamp(1, total);
    final buttons = <Widget>[];

    for (var i = start; i <= end; i++) {
      final active = i == current;
      buttons.add(
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: active || state.isRefreshing
                ? null
                : () => context.read<OrdersBloc>().add(ChangePage(i)),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? const Color(0xFF0F172A) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              child: Text(
                '$i',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          ),
        ),
      );
      if (i < end) buttons.add(const SizedBox(width: 4));
    }
    return buttons;
  }

  Widget _buildSkeleton(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: (Responsive.isMobile(context) ? 1 : 3) * 2,
        gridDelegate: _gridDelegate(context),
        itemBuilder: (context, index) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
    );
  }

  Widget _buildMessage({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? action,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 44, color: const Color(0xFFCBD5E1)),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.sora(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF475569),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 12), action],
          ],
        ),
      ),
    );
  }

  void _openDetails(BuildContext context, OrderModel order) {
    context.push(AppRoutes.kitchenOrderDetails.path, extra: order);
  }
}

class _LiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFBBF7D0)),
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
          Text(
            'Live',
            style: GoogleFonts.sora(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF16A34A),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final bool loading;
  final VoidCallback onTap;

  const _IconAction({
    required this.icon,
    required this.loading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: loading ? null : onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(9),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(icon, size: 18, color: const Color(0xFF334155)),
        ),
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final bool iconAfter;

  const _PageButton({
    required this.label,
    required this.icon,
    required this.enabled,
    required this.onTap,
    this.iconAfter = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled ? Colors.white : const Color(0xFFF1F5F9),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!iconAfter) ...[
                Icon(
                  icon,
                  size: 18,
                  color: enabled
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: enabled
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ),
              if (iconAfter) ...[
                const SizedBox(width: 4),
                Icon(
                  icon,
                  size: 18,
                  color: enabled
                      ? const Color(0xFF334155)
                      : const Color(0xFFCBD5E1),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
