import 'package:flutter/material.dart';
import 'package:airmenuai_partner_app/features/hotel_rooms/domain/entities/hotel_room_entity.dart';
import 'package:airmenuai_partner_app/utils/colors/airmenu_color.dart';
import 'package:airmenuai_partner_app/utils/typography/airmenu_typography.dart';

class GlobalRecentOrdersList extends StatefulWidget {
  final List<RoomOrder> orders;

  const GlobalRecentOrdersList({super.key, required this.orders});

  @override
  State<GlobalRecentOrdersList> createState() => _GlobalRecentOrdersListState();
}

class _GlobalRecentOrdersListState extends State<GlobalRecentOrdersList> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    // Sort by timestamp descending (newest first)
    final displayOrders = List<RoomOrder>.from(widget.orders)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Take top 5
    final topOrders = displayOrders.take(5).toList();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        height: 500,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()..translate(0.0, _isHovered ? -4.0 : 0.0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _isHovered
                ? AirMenuColors.primary.withOpacity(0.8)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.04),
              blurRadius: _isHovered ? 24 : 20,
              offset: _isHovered ? const Offset(0, 8) : const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Orders',
                  style: AirMenuTextStyle.large.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                InkWell(
                  onTap: () {},
                  child: Row(
                    children: const [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AirMenuColors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: AirMenuColors.textSecondary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: topOrders.isNotEmpty
                  ? ListView.builder(
                      itemCount: topOrders.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _buildOrderCard(topOrders[index]),
                        );
                      },
                    )
                  : const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("No recent orders"),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(RoomOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Room ${order.roomNumber}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  order.status.name.toLowerCase(),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.description, // Category e.g. Food
            style: const TextStyle(
              fontSize: 12,
              color: AirMenuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(order.title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}
