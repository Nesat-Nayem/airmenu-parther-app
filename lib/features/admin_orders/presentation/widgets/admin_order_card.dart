import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Admin Order Card for Live Orders Feed
/// Matches the reference mockup with restaurant name, items, order type, amount, time
class AdminOrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const AdminOrderCard({super.key, required this.order, this.onTap});

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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? const Color(0xFFDC2626).withValues(alpha: 0.4)
                      : Colors.grey.shade100,
                  width: hovered ? 2 : 1,
                ),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: const Color(
                            0xFFDC2626,
                          ).withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Row 1: Order ID + Status Badge
                  _buildHeader(),
                  const SizedBox(height: 16),
                  // Row 2: Restaurant Name
                  _buildRestaurantName(),
                  const SizedBox(height: 4),
                  // Row 3: Items Summary
                  _buildItemsSummary(),
                  const SizedBox(height: 16),
                  // Row 4: Order Type Badge + Amount
                  _buildOrderTypeAndAmount(),
                  const SizedBox(height: 12),
                  // Row 5: Time ago
                  _buildTimeAgo(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// Header: Order ID (left) + Status Badge (right)
  Widget _buildHeader() {
    final shortId = _getShortOrderId();
    final status = order.status?.toLowerCase() ?? 'pending';
    final statusInfo = _getStatusInfo(status);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Order ID - Bold, larger
        Text(
          '#$shortId',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF374151),
          ),
        ),
        // Status Badge with dot
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusInfo.bgColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: statusInfo.dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                statusInfo.label,
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: statusInfo.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Restaurant Name - Bold, prominent
  Widget _buildRestaurantName() {
    // Use hotel.name if hotelName is null
    final restaurantName =
        order.hotelName ?? order.hotel?.name ?? 'Unknown Restaurant';

    return Text(
      restaurantName,
      style: GoogleFonts.sora(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF111827),
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Items Summary - Comma separated
  Widget _buildItemsSummary() {
    final items = order.items ?? [];
    if (items.isEmpty) {
      return Text(
        'No items',
        style: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: Colors.grey.shade500,
        ),
      );
    }

    // Build items summary string
    final summaryParts = <String>[];
    for (final item in items.take(3)) {
      final name = item.menuItemData?.title ?? 'Item';
      final qty = item.quantity ?? 1;
      if (qty > 1) {
        summaryParts.add('$name x$qty');
      } else {
        summaryParts.add(name);
      }
    }
    if (items.length > 3) {
      summaryParts.add('+${items.length - 3} more');
    }

    return Text(
      summaryParts.join(', '),
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Order Type Badge + Amount + Delayed indicator
  Widget _buildOrderTypeAndAmount() {
    final orderType = order.orderType?.toLowerCase() ?? 'dine_in';
    final amount = order.totalAmount?.toInt() ?? 0;
    final isDelayed = _isDelayed();

    return Row(
      children: [
        _buildOrderTypeBadge(orderType),
        const Spacer(),
        // Amount
        Text(
          '₹$amount',
          style: GoogleFonts.sora(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        // Delayed indicator with warning icon
        if (isDelayed) ...[
          const SizedBox(width: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: 14,
                color: const Color(0xFFDC2626),
              ),
              const SizedBox(width: 4),
              Text(
                'Delayed',
                style: GoogleFonts.sora(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildOrderTypeBadge(String orderType) {
    Color bgColor;
    Color textColor;
    String label;

    switch (orderType) {
      case 'takeaway':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'takeaway';
        break;
      case 'delivery':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'delivery';
        break;
      default:
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'dine-in';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  /// Time ago - Bottom left
  Widget _buildTimeAgo() {
    final timeAgo = _getTimeAgoText();

    return Text(
      timeAgo,
      style: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: Colors.grey.shade500,
      ),
    );
  }

  String _getShortOrderId() {
    final id = order.id ?? '';
    if (id.length > 4) return id.substring(id.length - 4).toUpperCase();
    return id.padLeft(4, '0').toUpperCase();
  }

  String _getTimeAgoText() {
    if (order.createdAt == null) return 'Just now';
    try {
      final created = DateTime.parse(order.createdAt!);
      final diff = DateTime.now().difference(created);

      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${diff.inMinutes} min ago';
      }
    } catch (e) {
      return 'Just now';
    }
  }

  bool _isDelayed() {
    if (order.createdAt == null) return false;
    try {
      final created = DateTime.parse(order.createdAt!);
      final status = order.status?.toLowerCase() ?? '';
      if (status == 'delivered' || status == 'cancelled') return false;
      return DateTime.now().difference(created).inMinutes >
          OrderConfig.delayedThresholdMinutes;
    } catch (e) {
      return false;
    }
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return _StatusInfo(
          label: 'Pending',
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          dotColor: const Color(0xFFF59E0B),
        );
      case 'processing':
      case 'in-kitchen':
        return _StatusInfo(
          label: 'Preparing',
          bgColor: const Color(0xFFDCFCE7),
          textColor: const Color(0xFF16A34A),
          dotColor: const Color(0xFF22C55E),
        );
      case 'ready':
        return _StatusInfo(
          label: 'Ready',
          bgColor: const Color(0xFFDBEAFE),
          textColor: const Color(0xFF2563EB),
          dotColor: const Color(0xFF3B82F6),
        );
      case 'delivered':
        return _StatusInfo(
          label: 'Delivered',
          bgColor: const Color(0xFFF3F4F6),
          textColor: const Color(0xFF6B7280),
          dotColor: const Color(0xFF9CA3AF),
        );
      case 'cancelled':
        return _StatusInfo(
          label: 'Cancelled',
          bgColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
          dotColor: const Color(0xFFEF4444),
        );
      default:
        return _StatusInfo(
          label: 'Pending',
          bgColor: const Color(0xFFFEF3C7),
          textColor: const Color(0xFFD97706),
          dotColor: const Color(0xFFF59E0B),
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color dotColor;

  _StatusInfo({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.dotColor,
  });
}
