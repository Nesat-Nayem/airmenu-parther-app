import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
import 'package:airmenuai_partner_app/features/orders/config/order_status_helper.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Order Card for Kanban board - matches Figma design exactly
/// Layout: Header (ID + Badge + KOT) > Order Type > Items > Timer/Station
class OrderCardNew extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onMenuTap;

  const OrderCardNew({
    super.key,
    required this.order,
    this.onTap,
    this.onMenuTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 10),
            _buildOrderType(),
            const SizedBox(height: 10),
            _buildItemsList(),
            const SizedBox(height: 12),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final shortId = _getShortOrderId();
    final priorityBadge = _getPriorityBadge();
    final kotNumber = _getKotNumber();

    return Row(
      children: [
        // Order ID - 4 digit format
        Text(
          '#$shortId',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        const SizedBox(width: 8),
        // Priority Badge (NORMAL/RUSH/VIP)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: priorityBadge.bgColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            priorityBadge.label,
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: priorityBadge.textColor,
            ),
          ),
        ),
        const Spacer(),
        // KOT number
        Text(
          kotNumber,
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderType() {
    final orderType = order.orderType?.toUpperCase() ?? 'DINE_IN';
    final tableNumber = order.tableNumber ?? '';

    String displayType;
    IconData icon;

    switch (orderType) {
      case 'TAKEAWAY':
        displayType = 'Takeaway';
        icon = Icons.shopping_bag_outlined;
        break;
      case 'DELIVERY':
        displayType = 'Delivery';
        icon = Icons.delivery_dining_outlined;
        break;
      default:
        displayType = 'Dine In';
        icon = Icons.restaurant_outlined;
    }

    return Row(
      children: [
        Icon(icon, size: 14, color: const Color(0xFFDC2626)),
        const SizedBox(width: 6),
        Text(
          displayType,
          style: AirMenuTextStyle.small.copyWith(
            color: const Color(0xFFDC2626),
            fontWeight: FontWeight.w500,
          ),
        ),
        // Table number with T-XX format (2 digits with leading zero)
        if (tableNumber.isNotEmpty) ...[
          Text(
            ' • ',
            style: AirMenuTextStyle.small.copyWith(color: Colors.grey.shade400),
          ),
          Text(
            'T-${tableNumber.padLeft(2, '0')}',
            style: AirMenuTextStyle.small.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildItemsList() {
    final items = order.items ?? [];
    final displayItems = items.take(2).toList();
    final remainingCount = items.length - 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...displayItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.menuItemData?.title ?? 'Unknown Item',
                    style: AirMenuTextStyle.small.copyWith(
                      color: Colors.grey.shade700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '×${item.quantity ?? 1}',
                  style: AirMenuTextStyle.small.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (remainingCount > 0)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '+$remainingCount more items',
              style: AirMenuTextStyle.caption.copyWith(
                color: Colors.grey.shade400,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFooter() {
    final elapsedTime = _getElapsedTimeFormatted();
    final eta = _getETA();
    final station = _getKitchenStation();
    final isDelayed = _isDelayed();

    return Row(
      children: [
        // Timer with icon - format: "3 min" or "2h" or "25d"
        Icon(
          Icons.access_time_rounded,
          size: 14,
          color: isDelayed ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
        ),
        const SizedBox(width: 4),
        Text(
          elapsedTime,
          style: AirMenuTextStyle.small.copyWith(
            color: isDelayed
                ? const Color(0xFFDC2626)
                : const Color(0xFF16A34A),
            fontWeight: FontWeight.w600,
          ),
        ),
        if (eta > 0) ...[
          const SizedBox(width: 6),
          Text(
            '• ETA: $eta min',
            style: AirMenuTextStyle.caption.copyWith(
              color: Colors.grey.shade500,
            ),
          ),
        ],
        const Spacer(),
        // Station badge (Grill, Rice, Fry, etc.)
        if (station.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              station,
              style: AirMenuTextStyle.caption.copyWith(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  // Get 4-digit order ID
  String _getShortOrderId() {
    final id = order.id ?? '';
    if (id.length > 4) return id.substring(id.length - 4).toUpperCase();
    return id.padLeft(4, '0').toUpperCase();
  }

  String _getKotNumber() {
    final id = order.id ?? '';
    return 'KOT-${id.length > 3 ? id.substring(id.length - 3) : id}';
  }

  _PriorityBadge _getPriorityBadge() {
    // Check if VIP (paid orders)
    if (order.paymentStatus?.toLowerCase() == 'paid') {
      return _PriorityBadge(
        label: 'VIP',
        bgColor: OrderStatusHelper.vipBgColor,
        textColor: OrderStatusHelper.vipTextColor,
      );
    }
    // Check if delayed (RUSH)
    if (_isDelayed()) {
      return _PriorityBadge(
        label: 'RUSH',
        bgColor: OrderStatusHelper.rushBgColor,
        textColor: OrderStatusHelper.rushTextColor,
      );
    }
    // Normal
    return _PriorityBadge(
      label: 'NORMAL',
      bgColor: Colors.grey.shade200,
      textColor: Colors.grey.shade700,
    );
  }

  bool _isDelayed() {
    if (order.createdAt == null) return false;
    try {
      final created = DateTime.parse(order.createdAt!);
      return DateTime.now().difference(created).inMinutes >
          OrderConfig.delayedThresholdMinutes;
    } catch (e) {
      return false;
    }
  }

  // Returns human-readable elapsed time: "3 min", "2h", "25d"
  String _getElapsedTimeFormatted() {
    if (order.createdAt == null) return '0 min';
    try {
      final created = DateTime.parse(order.createdAt!);
      final diff = DateTime.now().difference(created);

      if (diff.inDays > 0) {
        return '${diff.inDays}d';
      } else if (diff.inHours > 0) {
        return '${diff.inHours}h';
      } else {
        return '${diff.inMinutes} min';
      }
    } catch (e) {
      return '0 min';
    }
  }

  int _getETA() {
    if (order.createdAt == null) return 0;
    try {
      final created = DateTime.parse(order.createdAt!);
      final eta = created.add(Duration(minutes: OrderConfig.defaultEtaMinutes));
      final remaining = eta.difference(DateTime.now());
      if (remaining.isNegative) return 0;
      return remaining.inMinutes;
    } catch (e) {
      return 0;
    }
  }

  String _getKitchenStation() {
    final items = order.items ?? [];
    if (items.isEmpty) return '';
    final station = items.first.station;
    if (station == null || station.isEmpty) return '';
    // Format station name (e.g., grill -> Grill, main_course -> Main Course)
    return station
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isNotEmpty
              ? '${word[0].toUpperCase()}${word.substring(1)}'
              : '',
        )
        .join(' ');
  }
}

class _PriorityBadge {
  final String label;
  final Color bgColor;
  final Color textColor;

  _PriorityBadge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });
}
