import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/dashboard/data/models/vendor/vendor_dashboard_models.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class RecentOrdersTable extends StatelessWidget {
  final List<RecentOrderModel> orders;
  final VoidCallback? onViewAll;

  const RecentOrdersTable({super.key, required this.orders, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AirMenuColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AirMenuColors.borderDefault, width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Recent Orders',
                    style: AirMenuTextStyle.headingH4.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AirMenuColors.textPrimary,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: onViewAll,
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: const Text('View All Orders'),
                  style: TextButton.styleFrom(
                    foregroundColor: AirMenuColors.primary,
                  ),
                ),
              ],
            ),
          ),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                'No recent orders',
                style: AirMenuTextStyle.normal.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  return _buildDesktopTable();
                } else {
                  return _buildMobileList();
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopTable() {
    return Column(
      children: [
        // Table header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: AirMenuColors.backgroundSecondary,
            border: Border(
              top: BorderSide(color: AirMenuColors.borderDefault, width: 1),
            ),
          ),
          child: Row(
            children: [
              _buildHeaderCell('ORDER ID', flex: 2),
              _buildHeaderCell('TYPE', flex: 2),
              _buildHeaderCell('TABLE/SOURCE', flex: 2),
              _buildHeaderCell('ITEMS', flex: 2),
              _buildHeaderCell('STATUS', flex: 2),
              _buildHeaderCell('TIME', flex: 2),
              const SizedBox(width: 40), // For action button
            ],
          ),
        ),
        // Table rows
        ...orders.map((order) => _buildDesktopRow(order)),
      ],
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: AirMenuTextStyle.caption.copyWith(
          color: AirMenuColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 11,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildDesktopRow(RecentOrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AirMenuColors.borderDefault, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              order.orderId,
              style: AirMenuTextStyle.normal.copyWith(
                fontWeight: FontWeight.w600,
                color: AirMenuColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildOrderTypeBadge(order),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.tableSource,
              style: AirMenuTextStyle.normal.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${order.itemCount} items',
              style: AirMenuTextStyle.normal.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: _buildStatusBadge(order),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              order.timeAgo,
              style: AirMenuTextStyle.small.copyWith(
                color: AirMenuColors.textSecondary,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Show order actions menu
            },
            icon: const Icon(Icons.more_horiz),
            iconSize: 20,
            color: AirMenuColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileList() {
    return Column(
      children: orders.map((order) => _buildMobileCard(order)).toList(),
    );
  }

  Widget _buildMobileCard(RecentOrderModel order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: AirMenuColors.borderDefault, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                order.orderId,
                style: AirMenuTextStyle.normal.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AirMenuColors.textPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {
                  // TODO: Show order actions menu
                },
                icon: const Icon(Icons.more_horiz),
                iconSize: 20,
                color: AirMenuColors.textSecondary,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildOrderTypeBadge(order),
              const SizedBox(width: 12),
              Text(
                order.tableSource,
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
              const Spacer(),
              _buildStatusBadge(order),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '${order.itemCount} items',
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                order.timeAgo,
                style: AirMenuTextStyle.small.copyWith(
                  color: AirMenuColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOrderTypeBadge(RecentOrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: order.orderTypeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        order.orderType,
        style: AirMenuTextStyle.caption.copyWith(
          color: order.orderTypeColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(RecentOrderModel order) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: order.statusBackgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        order.status,
        style: AirMenuTextStyle.caption.copyWith(
          color: order.statusColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
