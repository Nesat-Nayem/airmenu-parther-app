import 'package:airmenuai_partner_app/features/orders/config/order_status_helper.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

/// Order detail dialog/popup with full order information
/// Matches Figma design exactly with status tabs, info grid, items, and action buttons
class OrderDetailDialog extends StatelessWidget {
  final OrderModel order;
  final Function(String)? onStatusChange;
  final VoidCallback? onClose;

  const OrderDetailDialog({
    super.key,
    required this.order,
    this.onStatusChange,
    this.onClose,
  });

  String get _shortOrderId {
    final id = order.id ?? '';
    return id.length > 4 ? id.substring(id.length - 4).toUpperCase() : id;
  }

  String get _kotNumber {
    final id = order.id ?? '';
    return 'KOT-${id.length > 3 ? id.substring(id.length - 3) : id}';
  }

  String get _source {
    final orderType = order.orderType?.toLowerCase() ?? 'dine_in';
    switch (orderType) {
      case 'takeaway':
        return 'Takeaway';
      case 'delivery':
        return 'Delivery';
      default:
        return 'Dine In';
    }
  }

  String get _tableInfo {
    final table = order.tableNumber;
    return table != null && table.isNotEmpty ? 'T-$table' : 'N/A';
  }

  String get _station {
    final items = order.items ?? [];
    if (items.isEmpty) return 'N/A';
    final station = items.first.station;
    if (station == null || station.isEmpty) return 'N/A';
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

  String get _timeElapsed {
    if (order.createdAt == null) return 'N/A';
    try {
      final created = DateTime.parse(order.createdAt!);
      final diff = DateTime.now().difference(created);
      if (diff.inDays > 0) {
        return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''}';
      } else if (diff.inHours > 0) {
        return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''}';
      } else {
        return '${diff.inMinutes} min';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  // Use centralized status helper - no more duplicated switch statements!
  String get _statusLabel => OrderStatusHelper.getLabel(order.status);
  Color get _statusColor => OrderStatusHelper.getColor(order.status);
  String get _nextStatus => OrderStatusHelper.getNextStatus(order.status);
  String get _nextStatusButtonLabel =>
      OrderStatusHelper.getNextStatusButtonLabel(order.status);

  bool get _isVIP {
    return order.paymentStatus?.toLowerCase() == 'paid';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth > 500 ? 460.0 : screenWidth * 0.92;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: dialogWidth,
        constraints: const BoxConstraints(maxHeight: 640),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // FIXED HEADER SECTION
            // ═══════════════════════════════════════════════════════════════

            // Colored top strip bar (minimal)
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: _statusColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
            ),

            // Header row (Order ID + KOT + close button) with background
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 16, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #$_shortOrderId',
                    style: GoogleFonts.sora(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _kotNumber,
                          style: GoogleFonts.sora(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          child: Icon(
                            Icons.close,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Status badges row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  // Status badge (colored)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel,
                      style: AirMenuTextStyle.small.copyWith(
                        color: _statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Priority badge (NORMAL/VIP)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _isVIP
                          ? const Color(0xFFFEF3C7)
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isVIP
                            ? const Color(0xFFFCD34D)
                            : Colors.grey.shade200,
                      ),
                    ),
                    child: Text(
                      _isVIP ? 'VIP' : 'NORMAL',
                      style: AirMenuTextStyle.small.copyWith(
                        color: _isVIP
                            ? const Color(0xFFD97706)
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Info grid (Type, Location, Station, Time) - FIXED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Row 1: Type + Location
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoItem(label: 'Type', value: _source),
                        ),
                        Expanded(
                          child: _InfoItem(
                            label: 'Location',
                            value: _tableInfo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Row 2: Station + Time Elapsed
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoItem(label: 'Station', value: _station),
                        ),
                        Expanded(
                          child: _InfoItem(
                            label: 'Time Elapsed',
                            value: _timeElapsed,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════════════════
            // SCROLLABLE ITEMS SECTION
            // ═══════════════════════════════════════════════════════════════

            // Items header - FIXED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Items',
                  style: AirMenuTextStyle.small.copyWith(
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Items list - SCROLLABLE
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    ...?order.items?.map((item) => _buildItemRow(item)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ═══════════════════════════════════════════════════════════════
            // FIXED FOOTER SECTION (Total Amount + Buttons)
            // ═══════════════════════════════════════════════════════════════

            // Total Amount row - FIXED
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Divider(color: Colors.grey.shade200, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount',
                        style: AirMenuTextStyle.normal.copyWith(
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        NumberFormat.currency(
                          symbol: '₹',
                          decimalDigits: 0,
                          locale: 'en_IN',
                        ).format(order.totalAmount ?? 0),
                        style: AirMenuTextStyle.headingH4.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action buttons - FIXED with padding
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                children: [
                  // Primary action button
                  if (order.status?.toLowerCase() != 'delivered' &&
                      order.status?.toLowerCase() != 'cancelled')
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          onStatusChange?.call(_nextStatus);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(_nextStatusButtonLabel),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AirMenuColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: AirMenuTextStyle.button.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (order.status?.toLowerCase() != 'delivered' &&
                      order.status?.toLowerCase() != 'cancelled')
                    const SizedBox(width: 12),
                  // Cancel/Close button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: AirMenuTextStyle.button,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          const Text('Cancel'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItemModel item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              item.menuItemData?.title ?? 'Unknown Item',
              style: AirMenuTextStyle.normal.copyWith(
                color: Colors.grey.shade800,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '×${item.quantity ?? 1}',
            style: AirMenuTextStyle.normal.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AirMenuTextStyle.caption.copyWith(color: Colors.grey.shade500),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: AirMenuTextStyle.normal.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }
}
