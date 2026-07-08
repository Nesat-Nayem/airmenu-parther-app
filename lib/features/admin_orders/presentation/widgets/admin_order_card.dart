import 'package:airmenuai_partner_app/features/orders/config/order_config.dart';
import 'package:airmenuai_partner_app/features/orders/data/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

/// Shared grid geometry so cards + skeletons stay the same height.
abstract final class AdminOrderCardLayout {
  static const double radius = 16;
  static const EdgeInsets padding = EdgeInsets.fromLTRB(16, 14, 16, 12);
  static const Color idleBorder = Color(0xFFECE8E6);
  static const Color accent = Color(0xFFD4353A);

  /// Compact content stack height used by grids + skeletons.
  static const double cardHeight = 172;
}

/// Admin Live Orders Feed card — Lovable glass-card layout.
/// Hover: soft coral border + glow only (fixed 1px border, MouseTracker-safe).
class AdminOrderCard extends StatefulWidget {
  final OrderModel order;
  final VoidCallback? onTap;

  const AdminOrderCard({super.key, required this.order, this.onTap});

  @override
  State<AdminOrderCard> createState() => _AdminOrderCardState();
}

class _AdminOrderCardState extends State<AdminOrderCard> {
  bool _hovered = false;

  static const _foreground = Color(0xFF2A3038);
  static const _muted = Color(0xFF7A8494);

  OrderModel get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final isDelayed = _isDelayed();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        if (!_hovered) setState(() => _hovered = true);
      },
      onExit: (_) {
        if (_hovered) setState(() => _hovered = false);
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final hasBoundedHeight = constraints.maxHeight.isFinite;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: double.infinity,
              height: hasBoundedHeight ? double.infinity : null,
              padding: AdminOrderCardLayout.padding,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AdminOrderCardLayout.radius),
                border: Border.all(
                  color: isDelayed
                      ? const Color(0xFFEF4444).withValues(alpha: 0.35)
                      : (_hovered
                          ? AdminOrderCardLayout.accent.withValues(alpha: 0.45)
                          : AdminOrderCardLayout.idleBorder),
                  width: 1,
                ),
                boxShadow: _hovered
                    ? [
                        BoxShadow(
                          color: AdminOrderCardLayout.accent
                              .withValues(alpha: 0.18),
                          blurRadius: 22,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: AdminOrderCardLayout.accent
                              .withValues(alpha: 0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.045),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 8),
                  _buildRestaurantName(),
                  const SizedBox(height: 2),
                  _buildItemsSummary(),
                  const SizedBox(height: 10),
                  _buildTypeAndAmount(),
                  const SizedBox(height: 10),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: AdminOrderCardLayout.idleBorder
                        .withValues(alpha: 0.9),
                  ),
                  const SizedBox(height: 8),
                  _buildFooter(isDelayed),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final shortId = _getShortOrderId();
    final status = order.status?.toLowerCase() ?? 'pending';
    final statusInfo = _getStatusInfo(status);

    return Row(
      children: [
        Text(
          '#$shortId',
          style: GoogleFonts.sora(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: _foreground,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
          decoration: BoxDecoration(
            color: statusInfo.bgColor,
            borderRadius: BorderRadius.circular(999),
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
              const SizedBox(width: 5),
              Text(
                statusInfo.label,
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusInfo.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRestaurantName() {
    final restaurantName =
        order.hotelName ?? order.hotel?.name ?? 'Unknown Restaurant';

    return Text(
      restaurantName,
      style: GoogleFonts.sora(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: _foreground,
        height: 1.25,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildItemsSummary() {
    final items = order.items ?? [];
    if (items.isEmpty) {
      return Text(
        'No items',
        style: GoogleFonts.sora(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: _muted,
          height: 1.3,
        ),
      );
    }

    final summaryParts = <String>[];
    for (final item in items.take(2)) {
      final name = item.menuItemData?.title ?? 'Item';
      final qty = item.quantity ?? 1;
      if (qty > 1) {
        summaryParts.add('$name x$qty');
      } else {
        summaryParts.add(name);
      }
    }
    if (items.length > 2) {
      summaryParts.add('+${items.length - 2} more');
    }

    return Text(
      summaryParts.join(', '),
      style: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: _muted,
        height: 1.3,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTypeAndAmount() {
    final orderType = order.orderType?.toLowerCase() ?? 'dine_in';
    final amount = order.totalAmount?.toInt() ?? 0;

    return Row(
      children: [
        _buildOrderTypeBadge(orderType),
        const Spacer(),
        Text(
          '₹$amount',
          style: GoogleFonts.sora(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _foreground,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(bool isDelayed) {
    return Row(
      children: [
        Text(
          _getTimeAgoText(),
          style: GoogleFonts.sora(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const Spacer(),
        if (isDelayed)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 13,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 4),
              Text(
                'Delayed',
                style: GoogleFonts.sora(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildOrderTypeBadge(String orderType) {
    late final Color bgColor;
    late final Color textColor;
    late final String label;

    switch (orderType) {
      case 'takeaway':
      case 'pickup':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        label = 'takeaway';
        break;
      case 'delivery':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF16A34A);
        label = 'delivery';
        break;
      case 'room_service':
      case 'room-service':
        bgColor = const Color(0xFFE0E7FF);
        textColor = const Color(0xFF4F46E5);
        label = 'room-service';
        break;
      default:
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        label = 'dine-in';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: GoogleFonts.sora(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
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
      } else if (diff.inMinutes > 0) {
        return '${diff.inMinutes} min ago';
      }
      return 'Just now';
    } catch (e) {
      return 'Just now';
    }
  }

  bool _isDelayed() {
    if (order.createdAt == null) return false;
    try {
      final created = DateTime.parse(order.createdAt!);
      final status = order.status?.toLowerCase() ?? '';
      if (status == 'delivered' ||
          status == 'cancelled' ||
          status == 'completed') {
        return false;
      }
      return DateTime.now().difference(created).inMinutes >
          OrderConfig.delayedThresholdMinutes;
    } catch (e) {
      return false;
    }
  }

  _StatusInfo _getStatusInfo(String status) {
    switch (status) {
      case 'pending':
        return const _StatusInfo(
          label: 'Pending',
          bgColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFD97706),
          dotColor: Color(0xFFF59E0B),
        );
      case 'processing':
      case 'in-kitchen':
      case 'preparing':
        return const _StatusInfo(
          label: 'Preparing',
          bgColor: Color(0xFFFFEDD5),
          textColor: Color(0xFFEA580C),
          dotColor: Color(0xFFF97316),
        );
      case 'ready':
        return const _StatusInfo(
          label: 'Ready',
          bgColor: Color(0xFFDCFCE7),
          textColor: Color(0xFF16A34A),
          dotColor: Color(0xFF22C55E),
        );
      case 'delivered':
      case 'completed':
        return const _StatusInfo(
          label: 'Delivered',
          bgColor: Color(0xFFF3F4F6),
          textColor: Color(0xFF6B7280),
          dotColor: Color(0xFF9CA3AF),
        );
      case 'cancelled':
        return const _StatusInfo(
          label: 'Cancelled',
          bgColor: Color(0xFFFEE2E2),
          textColor: Color(0xFFDC2626),
          dotColor: Color(0xFFEF4444),
        );
      default:
        return const _StatusInfo(
          label: 'Pending',
          bgColor: Color(0xFFFEF3C7),
          textColor: Color(0xFFD97706),
          dotColor: Color(0xFFF59E0B),
        );
    }
  }
}

class _StatusInfo {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color dotColor;

  const _StatusInfo({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.dotColor,
  });
}

/// Skeleton that mirrors [AdminOrderCard] structure + height.
class AdminOrderCardSkeleton extends StatelessWidget {
  const AdminOrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFECE8E6),
      highlightColor: const Color(0xFFF8F6F4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final hasBoundedHeight = constraints.maxHeight.isFinite;
          return Container(
            width: double.infinity,
            height: hasBoundedHeight
                ? double.infinity
                : AdminOrderCardLayout.cardHeight,
            padding: AdminOrderCardLayout.padding,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
                  BorderRadius.circular(AdminOrderCardLayout.radius),
              border: Border.all(color: AdminOrderCardLayout.idleBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _bone(width: 52, height: 14, radius: 4),
                    const Spacer(),
                    _bone(width: 78, height: 22, radius: 999),
                  ],
                ),
                const SizedBox(height: 8),
                _bone(width: 140, height: 14, radius: 4),
                const SizedBox(height: 6),
                _bone(width: double.infinity, height: 11, radius: 4),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _bone(width: 64, height: 22, radius: 6),
                    const Spacer(),
                    _bone(width: 48, height: 14, radius: 4),
                  ],
                ),
                const SizedBox(height: 10),
                Container(height: 1, color: AdminOrderCardLayout.idleBorder),
                const SizedBox(height: 8),
                _bone(width: 72, height: 11, radius: 4),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _bone({
    required double height,
    required double radius,
    double? width,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
