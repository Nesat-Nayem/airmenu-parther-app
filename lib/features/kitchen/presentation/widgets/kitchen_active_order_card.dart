import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Compact, modern order card for the Kitchen panel active-orders grid.
class KitchenActiveOrderCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const KitchenActiveOrderCard({
    super.key,
    required this.order,
    this.onTap,
  });

  @override
  State<KitchenActiveOrderCard> createState() => _KitchenActiveOrderCardState();
}

class _KitchenActiveOrderCardState extends State<KitchenActiveOrderCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final status = widget.order.status?.toLowerCase() ?? 'pending';
    final accent = _statusAccent(status);
    final shortId = _shortId(widget.order.id);
    final items = widget.order.items ?? [];
    final amount = widget.order.totalAmount?.round() ?? 0;
    final table = widget.order.tableNumber?.trim();
    final orderType = widget.order.orderType?.toLowerCase() ?? 'dine_in';

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          transform: Matrix4.identity()
            ..translateByDouble(0.0, _hovered ? -3.0 : 0.0, 0.0, 1.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: _hovered
                  ? accent.withValues(alpha: 0.45)
                  : const Color(0xFFE8ECF1),
              width: _hovered ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: _hovered
                    ? accent.withValues(alpha: 0.14)
                    : Colors.black.withValues(alpha: 0.05),
                blurRadius: _hovered ? 22 : 12,
                offset: Offset(0, _hovered ? 10 : 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Status accent bar
                Container(height: 4, color: accent),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      Row(
                        children: [
                          Text(
                            '#$shortId',
                            style: GoogleFonts.sora(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          _StatusPill(status: status, accent: accent),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.restaurant_rounded,
                            label: _orderTypeLabel(orderType),
                            color: const Color(0xFF6366F1),
                          ),
                          if (table != null && table.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            _MetaChip(
                              icon: Icons.table_restaurant_rounded,
                              label: 'T-$table',
                              color: const Color(0xFFDC2626),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (items.isNotEmpty)
                        ...items.take(2).map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${item.quantity ?? 1}',
                                    style: GoogleFonts.sora(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    item.menuItemData?.title ?? 'Item',
                                    style: GoogleFonts.inter(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF475569),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (items.length > 2)
                        Text(
                          '+${items.length - 2} more items',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Text(
                              '₹$amount',
                              style: GoogleFonts.sora(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                            const Spacer(),
                            _PaymentChip(
                              status:
                                  widget.order.paymentStatus?.toLowerCase() ??
                                      'pending',
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule_rounded,
                              size: 13,
                              color: const Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _timeAgo(widget.order.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
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
    );
  }

  String _shortId(String? id) {
    if (id == null || id.isEmpty) return '0000';
    return id.length > 4
        ? id.substring(id.length - 4).toUpperCase()
        : id.padLeft(4, '0').toUpperCase();
  }

  String _orderTypeLabel(String type) {
    switch (type) {
      case 'takeaway':
        return 'Takeaway';
      case 'delivery':
        return 'Delivery';
      default:
        return 'Dine-in';
    }
  }

  String _timeAgo(String? createdAt) {
    if (createdAt == null) return 'now';
    try {
      final diff = DateTime.now().difference(DateTime.parse(createdAt));
      if (diff.inDays > 0) return '${diff.inDays}d';
      if (diff.inHours > 0) return '${diff.inHours}h';
      return '${diff.inMinutes}m';
    } catch (_) {
      return 'now';
    }
  }

  Color _statusAccent(String status) {
    switch (status) {
      case 'processing':
      case 'in-kitchen':
        return const Color(0xFF16A34A);
      case 'ready':
        return const Color(0xFF2563EB);
      case 'delivered':
        return const Color(0xFF64748B);
      case 'cancelled':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFF59E0B);
    }
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  final Color accent;

  const _StatusPill({required this.status, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _label(status),
        style: GoogleFonts.sora(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  String _label(String status) {
    switch (status) {
      case 'processing':
      case 'in-kitchen':
        return 'PREPARING';
      case 'ready':
        return 'READY';
      case 'delivered':
        return 'DONE';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return 'PENDING';
    }
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.sora(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentChip extends StatelessWidget {
  final String status;

  const _PaymentChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final isPaid = status == 'paid';
    final color = isPaid ? const Color(0xFF16A34A) : const Color(0xFFF59E0B);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: GoogleFonts.sora(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
